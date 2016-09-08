# TecheryTest description 

Initial requirements for the project: [gist](https://gist.github.com/soxjke/d4b13c772569a7188d5741afa32f2cef)
</br>

## Architectural considerations

<ul>
<li>MVVM-C as main architecture</li>
<li>BDD unit tests powered by Kiwi</li>
</ul>

## Some implementation details

<ul>
<li>Correct handling of account switching without reinstalling app</li>
<li>Simple handling of gaps between tweet feed loads by removing old tweets (temporary solution)</li>
<li>Using NSLog, as CocoaLumberjack or any other are is an overkill here</li>
<li>UsitTest are not fully finished</li> 
</ul>