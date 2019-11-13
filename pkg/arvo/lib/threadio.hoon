/+  libthread=thread
=,  thread=thread:libthread
=,  thread-fail=thread-fail:libthread
|%
++  send-raw-cards
  |=  cards=(list =card:agent:mall)
  =/  m  (thread ,~)
  ^-  form:m
  |=  thread-input:thread
  [cards %done ~]
::
++  send-raw-card
  |=  =card:agent:mall
  =/  m  (thread ,~)
  ^-  form:m
  (send-raw-cards card ~)
::
++  ignore
  |=  tin=thread-input:thread
  `[%fail %ignore ~]
::
++  get-bowl
  =/  m  (thread ,bowl:thread)
  ^-  form:m
  |=  tin=thread-input:thread
  `[%done bowl.tin]
::
++  get-time
  =/  m  (thread ,@da)
  ^-  form:m
  |=  tin=thread-input:thread
  `[%done now.bowl.tin]
::
++  get-our
  =/  m  (thread ,ship)
  ^-  form:m
  |=  tin=thread-input:thread
  `[%done our.bowl.tin]
::
++  get-entropy
  =/  m  (thread ,@uvJ)
  ^-  form:m
  |=  tin=thread-input:thread
  `[%done eny.bowl.tin]
::
::  Convert skips to %ignore failures.
::
::    This tells the main loop to try the next handler.
::
++  handle
  |*  a=mold
  =/  m  (thread ,a)
  |=  =form:m
  ^-  form:m
  |=  tin=thread-input:thread
  =/  res  (form tin)
  =?  next.res  ?=(%skip -.next.res)
    [%fail %ignore ~]
  res
::
::  Wait for a poke with a particular mark
::
++  take-poke
  |=  =mark
  =/  m  (thread ,vase)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %poke @ *]
    ?.  =(mark p.cage.u.in.tin)
      `[%skip ~]
    `[%done q.cage.u.in.tin]
  ==
::
::
::
++  take-sign-arvo
  =/  m  (thread ,[wire sign-arvo])
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %sign *]
    `[%done [wire sign-arvo]:u.in.tin]
  ==
::
::  Wait for a subscription update on a wire
::
++  take-fact-prefix
  |=  =wire
  =/  m  (thread ,[path cage])
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %fact *]
    ?.  =(watch+wire (scag (lent wire) wire.u.in.tin))
      `[%skip ~]
    `[%done (slag (lent wire) wire.u.in.tin) cage.sign.u.in.tin]
  ==
::
::  Wait for a subscription update on a wire
::
++  take-fact
  |=  =wire
  =/  m  (thread ,cage)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %fact *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done cage.sign.u.in.tin]
  ==
::
::  Wait for a subscription close
::
++  take-kick
  |=  =wire
  =/  m  (thread ,~)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %kick *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done ~]
  ==
::
++  echo
  =/  m  (thread ,~)
  ^-  form:m
  %-  (main-loop ,~)
  :~  |=  ~
      ^-  form:m
      ;<  =vase  bind:m  ((handle ,vase) (take-poke %echo))
      =/  message=tape  !<(tape vase)
      %-  (slog leaf+"{message}..." ~)
      ;<  ~      bind:m  (sleep ~s2)
      %-  (slog leaf+"{message}.." ~)
      (pure:m ~)
  ::
      |=  ~
      ^-  form:m
      ;<  =vase  bind:m  ((handle ,vase) (take-poke %over))
      %-  (slog leaf+"over..." ~)
      (pure:m ~)
  ==
::
++  take-watch
  =/  m  (thread ,path)
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %watch *]
    `[%done path.u.in.tin]
  ==
::
++  take-wake
  |=  until=(unit @da)
  =/  m  (thread ,~)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %sign [%wait @ ~] %b %wake *]
    ?.  |(?=(~ until) =(`u.until (slaw %da i.t.wire.u.in.tin)))
      `[%skip ~]
    ?~  error.sign-arvo.u.in.tin
      `[%done ~]
    `[%fail %timer-error u.error.sign-arvo.u.in.tin]
  ==
::
++  take-poke-ack
  |=  =wire
  =/  m  (thread ,~)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %poke-ack *]
    ?.  =(wire wire.u.in.tin)
      `[%skip ~]
    ?~  p.sign.u.in.tin
      `[%done ~]
    `[%fail %poke-fail u.p.sign.u.in.tin]
  ==
::
++  take-watch-ack
  |=  =wire
  =/  m  (thread ,~)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %watch-ack *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    ?~  p.sign.u.in.tin
      `[%done ~]
    `[%fail %watch-ack-fail u.p.sign.u.in.tin]
  ==
::
++  poke
  |=  [=dock =cage]
  =/  m  (thread ,~)
  ^-  form:m
  =/  =card:agent:mall  [%pass /poke %agent dock %poke cage]
  ;<  ~  bind:m  (send-raw-card card)
  (take-poke-ack /poke)
::
++  poke-our
  |=  [=term =cage]
  =/  m  (thread ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  (poke [our term] cage)
::
++  watch
  |=  [=wire =dock =path]
  =/  m  (thread ,~)
  ^-  form:m
  =/  =card:agent:mall  [%pass watch+wire %agent dock %watch path]
  ;<  ~  bind:m  (send-raw-card card)
  (take-watch-ack wire)
::
++  watch-our
  |=  [=wire =term =path]
  =/  m  (thread ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  (watch wire [our term] path)
::
++  leave
  |=  [=wire =dock]
  =/  m  (thread ,~)
  ^-  form:m
  =/  =card:agent:mall  [%pass watch+wire %agent dock %leave ~]
  (send-raw-card card)
::
++  leave-our
  |=  [=wire =term]
  =/  m  (thread ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  (leave wire [our term])
::
++  rewatch
  |=  [=wire =dock =path]
  =/  m  (thread ,~)
  ;<  ~  bind:m  ((handle ,~) (take-kick wire))
  ;<  ~  bind:m  (flog-text "rewatching {<dock>} {<path>}")
  ;<  ~  bind:m  (watch wire dock path)
  (pure:m ~)
::
++  wait
  |=  until=@da
  =/  m  (thread ,~)
  ^-  form:m
  ;<  ~  bind:m  (send-wait until)
  (take-wake `until)
::
++  sleep
  |=  for=@dr
  =/  m  (thread ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time
  (wait (add now for))
::
++  send-wait
  |=  until=@da
  =/  m  (thread ,~)
  ^-  form:m
  =/  =card:agent:mall
    [%pass /wait/(scot %da until) %arvo %b %wait until]
  (send-raw-card card)
::
++  set-timeout
  |*  computation-result=mold
  =/  m  (thread ,computation-result)
  |=  [time=@dr computation=form:m]
  ^-  form:m
  ;<  now=@da  bind:m  get-time
  =/  when  (add now time)
  =/  =card:agent:mall
    [%pass /timeout/(scot %da when) %arvo %b %wait when]
  ;<  ~        bind:m  (send-raw-card card)
  |=  tin=thread-input:thread
  =*  loop  $
  ?:  ?&  ?=([~ %sign [%timeout @ ~] %b %wake *] in.tin)
          =((scot %da when) i.t.wire.u.in.tin)
      ==
    `[%fail %timeout ~]
  =/  c-res  (computation tin)
  ?:  ?=(%cont -.next.c-res)
    c-res(self.next ..loop(computation self.next.c-res))
  ?:  ?=(%done -.next.c-res)
    =/  =card:agent:mall
      [%pass /timeout/(scot %da when) %arvo %b %rest when]
    c-res(cards [card cards.c-res])
  c-res
::
++  send-request
  |=  =request:http
  =/  m  (thread ,~)
  ^-  form:m
  (send-raw-card %pass /request %arvo %i %request request *outbound-config:iris)
::
++  send-cancel-request
  =/  m  (thread ,~)
  ^-  form:m
  (send-raw-card %pass /request %arvo %i %cancel-request ~)
::
++  take-client-response
  =/  m  (thread ,client-response:iris)
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %sign [%request ~] %i %http-response %finished *]
    `[%done client-response.sign-arvo.u.in.tin]
  ==
::
::  Wait until we get an HTTP response or cancelation and unset contract
::
++  take-maybe-sigh
  =/  m  (thread ,(unit httr:eyre))
  ^-  form:m
  ;<  rep=(unit client-response:iris)  bind:m
    take-maybe-response
  ?~  rep
    (pure:m ~)
  ::  XX s/b impossible
  ::
  ?.  ?=(%finished -.u.rep)
    (pure:m ~)
  (pure:m (some (to-httr:iris +.u.rep)))
::
++  take-maybe-response
  =/  m  (thread ,(unit client-response:iris))
  ^-  form:m
  |=  tin=thread-input:thread
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %sign [%request ~] %i %http-response %cancel *]
    `[%done ~]
      [~ %sign [%request ~] %i %http-response %finished *]
    `[%done `client-response.sign-arvo.u.in.tin]
  ==
::
++  extract-body
  |=  =client-response:iris
  =/  m  (thread ,cord)
  ^-  form:m
  ?>  ?=(%finished -.client-response)
  ?>  ?=(^ full-file.client-response)
  (pure:m q.data.u.full-file.client-response)
::
++  fetch-json
  |=  url=tape
  =/  m  (thread ,json)
  ^-  form:m
  =/  =request:http  [%'GET' (crip url) ~ ~]
  ;<  ~                      bind:m  (send-request request)
  ;<  =client-response:iris  bind:m  take-client-response
  ;<  =cord                  bind:m  (extract-body client-response)
  =/  json=(unit json)  (de-json:html cord)
  ?~  json
    (thread-fail %json-parse-error ~)
  (pure:m u.json)
::
::  Queue on skip, try next on fail %ignore
::
++  main-loop
  |*  a=mold
  =/  m  (thread ,~)
  =/  m-a  (thread ,a)
  =|  queue=(qeu (unit input:thread))
  =|  active=(unit [in=(unit input:thread) =form:m-a forms=(list $-(a form:m-a))])
  =|  state=a
  |=  forms=(lest $-(a form:m-a))
  ^-  form:m
  |=  tin=thread-input:thread
  =*  top  `form:m`..$
  =.  queue  (~(put to queue) in.tin)
  |^  (continue bowl.tin)
  ::
  ++  continue
    |=  =bowl:thread
    ^-  output:m
    ?>  =(~ active)
    ?:  =(~ queue)
      `[%cont top]
    =^  in=(unit input:thread)  queue  ~(get to queue)
    ^-  output:m
    =.  active  `[in (i.forms state) t.forms]
    ^-  output:m
    (run bowl in)
  ::
  ++  run
    ^-  form:m
    |=  tin=thread-input:thread
    ^-  output:m
    ?>  ?=(^ active)
    =/  res  (form.u.active tin)
    =/  =output:m
      ?-  -.next.res
          %wait  `[%wait ~]
          %skip  `[%cont ..$(queue (~(put to queue) in.tin))]
          %cont  `[%cont ..$(active `[in.u.active self.next.res forms.u.active])]
          %done  (continue(active ~, state value.next.res) bowl.tin)
          %fail
        ?:  &(?=(^ forms.u.active) ?=(%ignore p.err.next.res))
          %=  $
            active  `[in.u.active (i.forms.u.active state) t.forms.u.active]
            in.tin  in.u.active
          ==
        `[%fail err.next.res]
      ==
    [(weld cards.res cards.output) next.output]
  --
::
++  retry
  |*  result=mold
  |=  [crash-after=(unit @ud) computation=_*form:(thread (unit result))]
  =/  m  (thread ,result)
  =|  try=@ud
  |^  |-  ^-  form:m
      =*  loop  $
      ?:  =(crash-after `try)
        (thread-fail %retry-too-many ~)
      ;<  ~                  bind:m  (backoff try ~m1)
      ;<  res=(unit result)  bind:m  computation
      ?^  res
        (pure:m u.res)
      loop(try +(try))
  ::
  ++  backoff
    |=  [try=@ud limit=@dr]
    =/  m  (thread ,~)
    ^-  form:m
    ;<  eny=@uvJ  bind:m  get-entropy
    %-  sleep
    %+  min  limit
    ?:  =(0 try)  ~s0
    %+  add
      (mul ~s1 (bex (dec try)))
    (mul ~s0..0001 (~(rad og eny) 1.000))
  --
::
::    ----
::
::  Output
::
++  flog
  |=  =flog:dill
  =/  m  (thread ,~)
  ^-  form:m
  (send-raw-card %pass / %arvo %d %flog flog)
::
++  flog-text
  |=  =tape
  =/  m  (thread ,~)
  ^-  form:m
  (flog %text tape)
::
++  flog-tang
  |=  =tang
  =/  m  (thread ,~)
  ^-  form:m
  =/  =wall
    (zing (turn (flop tang) (cury wash [0 80])))
  |-  ^-  form:m
  =*  loop  $
  ?~  wall
    (pure:m ~)
  ;<  ~  bind:m  (flog-text i.wall)
  loop(wall t.wall)
::
::    ----
::
::  Handle domains
::
++  install-domain
  |=  =turf
  =/  m  (thread ,~)
  ^-  form:m
  (send-raw-card %pass / %arvo %e %rule %turf %put turf)
--