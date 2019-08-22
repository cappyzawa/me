# Concourse v5.0のGlobalResource
https://github.com/concourse/docs/blob/v5.0/lit/docs/global-resources.lit

## tl;dr
* そろそろリリースされる[concourse/concourse](https://github.com/concourse/concourse) v5.0から試験的に導入される `GlobalResource`について調べた
* GlobalResourceは管理者/運用者にとって嬉しい機能

## GlobalResource
https://github.com/concourse/docs/tree/v5.0 を手元でbuildしてリリースノートを確認した。  
何やらGlobalResourceというものが試験的に導入されるらしい。

> The basic concept of global resources is to share detected resource versions between all resources that have the same type and source configuration.

私見を交えつつ、GlobalResourceのpros/consを述べる。

_執筆現在(2019/02/20)はv5.0リリース前であるため、ここから変更の可能性がある。_

## pros
prosについて述べていくが大枠はドキュメントに従う。  

### Resourceのcheck回数を削減
GlobalResourceでは同じ設定をもつ全てのResourceがすべてのチームに渡って単一のresource check containerを利用するようになる。  

利用者からするとふーんという感じだが、これは運用者は小躍りせざるを得ない。  
それはConcourseの運用のつらみの1つがresource check containerの爆増だったからだ。  
Resourceは一定間隔でcheckされるのだが、そのタイミングでresource check containerができる。  
ちなみに一定間隔は調整可能( `--resource-checking-interval=` )だ。  
set-pipelineされた時点で初めてcheckが行われ、それ以降は指定された間隔にしたがってcheckが行われる。

ただ、メンテナンスや更新によりweb componentの再起動が発生した場合、再起動したときにすべてのresourceのcheckが走ってしまう。  
これにより、ばらばらのタイミングで行われていたResourceのcheckがほぼ同時に走るようになってしまう。  

1台のworker(Job実行Component)でさばけるContainer数は250台。  
仮にintervalが12hで、resourceの定義数が500だとすると、一定間隔でcontainer数が 500+α 台(αはJob実行により発生するcontainer) になりworkerが3台必要になる。  
通常時は1台のworkerで問題なく動作するものが、auto scaleなどの仕組みがないことから、この爆増に備えて常に3台で稼働させる必要がある。  

~~会社で使っているConcourseであれば別にいいが~~、自前で運用しているConcourseがあるとしたら費用がかさむ。  
(強引に理由をつけたが、自分はAWSやGCPでConcourseを運ようしているわけではない)

ともかく、resourceの定義数が多くなることに比例して、workerを増やす必要があったわけだ。  
このGlobal Resourceによって、同じ定義のResourceが1つにまとめられるとするとだいぶ緩和されそうだ。

そろそろここの説明は終了したいが、まだ続ける。

Concourseではunit-testなどの任意のスクリプトの実行はTaskを介して行われる。  
unit-testやなにかのbuildなど大抵どのパイプラインでも同じになることが多く、何度も同じTaskを記述するのは面倒だ。  
そうなってくるとConcourseのTaskを寄せ集めたrepositoryを作りたくなってくるのだ。  
そのTask repoを複数のpipelineで使いまわしたとしても、以前までは使いまわしたpipelineの数だけresource check containerが発生していた。  
これが1つになるとするとだいぶ緩和されそうな気がしてこないだろうか。

この説明の最後に少し細くを加える。  
実は以前までも同じ定義のResourceを1つにまとめるということはされていた。  
ただ、それはvolumeの話でcontainerの話ではなかった。  
なのできちんとv5.0でよりよくなった。

https://medium.com/concourse-ci/concourse-resource-volume-caching-7f4eb73be1a6

### 冗長なデータの削減が期待できる
大抵のResourceは外部にversion sourceがあるため、GlobalResourceによる恩恵を受けることができる。 
 
例をあげると、git-resourceやdocker-image-resourceである。git-resourceはcommit hashがversionされるし、docker-image-resourceは対象imageのdigestがversionされ、それぞれ対象のホスティングサービスが持っている情報である。  
これらのResourceはどのパイプラインから実行されても同じ設定(uriなど)であれば同じversionが返ってくる。

以前まではpipelineに紐づいたResourceごとにversionを持っていたから同じ設定の分だけ重複した情報を持っていた。

データサイズが小さくなるとバックアップにかかる時間の削減だとか、DBを運用するVMの肥大化防止につながって良い。

### Version Historyがより信頼できるものになる。
以前まで、もしくはv5.0でGlobalResourceを利用しない場合は、Resourceのversion historyはResource名に依存した。(びっくりするが本当の話)  
つまり以前まではResourceの定義名を変更せずに設定だけを変えると、versioningされる対象が変わってしまい、1つのResourceのversion historyの中に複数のtargetが存在する可能性があった。  

git-resourceでrepositoryのmasterブランチを対象をgetしていたが、動作確認のためdevブランチに向けた場合、そのResourceのhistoryにはmasterブランチのコミットハッシュとdevブランチのコミットハッシュが混在してしまっていたわけです。  
もっとひどい例だと、同じResource定義名でResourceTypeの設定を変えても同じhistoryとして管理されていたわけです。  
そのため常にデータ不整合が発生しうる状態だったし、実際にその状態になってしまった利用者のサポートも行ったことがある。  

GlobalResourceはResourceの種類と設定に厳密に依存するためこのような問題は発生しない。

## cons
### time-resourceなどの利用に懸念がある
[concourse/time\-resource: a resource for triggering on an interval](https://github.com/concourse/time-resource) の利用に懸念があるみたい。  
time-resourceはtimestampをversioningするresourceで、resourceの設定には実行のintervalなどを指定することできるresourceだ。  
Concourseを使ってcrontabチックな自動化を行いたいときにこのResourceは大活躍する。  
自分が仕事で運用しているConcourseでもヘビーユーザほどこのResourceを利用している人が多い印象がある。

さて、なぜ懸念があるかというと、同じresourceの設定からできたversion(timestamp)が同じ意味を持たないからだ。  
git-resourceであれば同じ設定(uri,branchなど)を指定するとversionとしてcommit hashが返ってくる。それは違うpipelineから実行されても同じである。　　  
しかし、time-resourceが同じ設定(intervalなど)でversionとして返ってくるtimestampであるため、異なる結果が返ってきてしまう。  
これではGlobalResourceのprosを活かせない。

ここまでを読んで、**利用できないわけではない**。 一応原文の見出しを貼っておく。

historyがGlobalResourceの思想通りに動作しないだけで、定期実行のトリガー用途に利用することができる。  
自分のlocal環境で最新のmasterをもってきてみたのだが、正常に動作した。  
さらに、不必要にhistoryが汚染されている様子もみられなかった。。。  
実際に5.0.0がリリースされてからここらへんは調査しないと意図せず利用者に影響がでてしまいそう。

### admin以外がresource check containerにinterceptできなくなる
v5.0からRBACが導入された影響で、resource check containerにinterceptできなくなったらしい。 
GlobalResourceであるとチームをまたいでGlobalになるため、セキュリティを考慮してとのことだった。 

interceptをよく使うのはtaskのdebugなどであるため、大きな影響はなさそうだ。

## 所感
* GlobalResourceは運用者/利用者にとって嬉しい機能
* resource check containerや重複データの削減で運用者は嬉しい
* Version Histroyがより厳密になり利用者は嬉しい(?)
