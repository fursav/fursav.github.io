---
title: "Mithril Sortable Table - Part 3"
about: "Introducing Mithril - Computed columns and randomized data"
date: 2014-09-15
---
In [Part 2][1], we improved our table by implementing initial sort and addding another column. In this post, we will add a computed column to our table and will allow the user to randomize the data.

Computed Column
---------------

Let's update our table to be a display of player statistics of some sport. Rename the 'Value' column to be 'Points' column and let's say all the players have played the same number of games. It would make sense for us to display the average number of points per game.

The big question is where should we compute that field. In our current structure, the model holds an array of primitives and it would require a lot of refactoring to change that. So that rules out the model. Accomodating a special column in the view would also require some refactoring. The controller seems to me to be the path of least resistance. Since the data in the controller is already a function (i.e. a computed field), adding another computation should be fairly simple. 

After modifying our table header to include another column, all we have to do is insert this loop at the top of our `controller.data` function.
```language-javascript
table.data.forEach(function(player) {
    player.avg = Math.floor(player.points*10/30)/10;
});
```
```language-coffeescript
for player in table.data
    player.avg = Math.floor(player.points*10/30)/10
});
```

[JSFiddle][2]

Random Data
-----------

Let's add a randomize button to our little table. First, let's update our view.

``` language-javascript
var button = m("button",{onclick: ctrl.handleButtonClick},"Generate Players");
var tableView = m("table", {onclick: ctrl.handleTableClick},[head,body]);
return m("div",[button,tableView]);
```
``` language-coffeescript
button = m("button",{onclick: ctrl.handleButtonClick},"Generate Players")
tableView = m("table", {onclick: ctrl.handleTableClick},[head,body])
return m("div",[button,tableView])
```

Second, let's add a bunch of utility functions to generate random data for us.

``` language-javascript
firstNames = ["James", "John", "Robert", "Michael", "William", "David", "Richard",
    "Charles", "Joseph", "Thomas"
];
lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis",
    "Garcia", "Rodriguez", "Wilson"
];

getRandomFromArr = function(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
};

genName = function() {
    var fname = getRandomFromArr(firstNames);
    var lname = getRandomFromArr(lastNames);
    return fname + ' ' + lname;
};

genPoints = function() {
    return Math.floor(Math.random() * 500) + 500;
};

genPlayer = function() {
    return {
        name: genName(),
        points: genPoints()
    };
};
```
``` language-coffeescript
firstNames = ["James","John","Robert","Michael","William","David","Richard",
             "Charles","Joseph","Thomas"]
lastNames = ["Smith","Johnson","Williams","Brown","Jones","Miller","Davis",
             "Garcia","Rodriguez","Wilson"]
    
getRandomFromArr = (arr) ->
    return arr[Math.floor(Math.random()*arr.length)]

genName = ->
    fname = getRandomFromArr(firstNames)
    lname = getRandomFromArr(lastNames)
    return fname + ' ' + lname

genValue = ->
    return Math.floor(Math.random()*500)+500

genPlayer = ->
    return {
            name: genName()
            value: genValue()
            }
```

Finally, let's add `controller.numPlayers` field that holds the number of player to generate and `controller.handleButtonClick` function that will invoke data randomization.
``` language-javascript
this.handleButtonClick = function (e) {
    var newData = [];
    var i = 0;
    while (i < this.numPlayers()) {
        newData.push(genPlayer());
        i++;
    }
    table.data = newData;            
}.bind(this);
```
``` language-coffeescript
@handleButtonClick = (e) =>
    newData = []
    i = 0
    while i < @numPlayers()
        newData.push(genPlayer())
        i++
    table.data = newData
    return
```

[JSFiddle][3]

User Input
----------

To finish things off, let's allow the user to decide how many players to generate. Simply add an input field to our view.
``` language-javascript
var input = m("input", {
    onchange: m.withAttr("value", ctrl.numPlayers),
    value: ctrl.numPlayers()
});
```
``` language-coffeescript
input = m("input",{onchange: m.withAttr("value", ctrl.numPlayers)})
```

[JSFiddle][4]

The line of code `onchange: m.withAttr("value", ctrl.numPlayers)` provides us with data binding in the view-to-model direction while `value: ctrl.numPlayers()` binds in the model-to-view direction. This is also known as bidirectional data-binding.

This completes the introduction to Mithril. Hopefully, you understand this tiny library a little more.

[1]: mithril-sort-2.html "Part 2"
[2]: http://jsfiddle.net/jjk8bxeq/24/
[3]: http://jsfiddle.net/jjk8bxeq/25/
[4]: http://jsfiddle.net/jjk8bxeq/26/