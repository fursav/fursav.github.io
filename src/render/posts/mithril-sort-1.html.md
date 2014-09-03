---
title: "Mithril Sortable Table - Part 1"
about: "Introducing Mithril - highly performant javascript MVC library. How to create a sortable table."
date: 2014-08-30
---

The front end development world of javascript is full of frameworks. When developing a web application, it makes sense to build on top of a framework with a good community rather than try to reinvent the wheel. After eliminating opininated and complicated frameworks, I ended up using [KnockoutJS][1]. It's a small two-way binding library with easy to use syntax that you can pick up in 5 minutes. However, it's not very efficient in dealing with arrays. After doing more research, I think frameworks that reduce or even eliminate DOM manipulation (since this is where most of the performance issues come from) by the programmer are the future. Currently, the popular technique to reduce DOM manipulation is virtual DOM diffing. And [React][2] is the most popular framework utilizing that technique. I encourage you to read a [post][3] by James Long to learn more about it. Then there are also a few other frameworks - [RactiveJS][4], [Mercury][5], and [Famous][6]. I have decided that I am going to try to learn [Mithril][7]. It's very lightweight, has great performance benchmarks, and it encourages you to write better code (as opposed to opinionated code) and therefore be a better developer. And since it's so small and simple, I don't see future versions of it breaking the api. 

Starting Out
------------

To get familiar with the framework, I decided to create a sortable table. I am not going to cover the basics of Mithril here since its website already has an excellent [guide][8]. Coincidentally, the author of Mithril has recently [posted][9] his own version of sortable table but I am going to take a slightly different and more thorough approach. 

To start off, let's create a table with a single column. 

``` language-javascript
var table = {
    data: [11,10,12],
    header: ["item"],
    controller: function() {
        this.data = m.prop(table.data);
        this.header = m.prop(table.header);
    },
    view: function(ctrl) {
        var head = ctrl.header().map(function (item,index) {
                return m("tr",[m("th",{class:"red"}, item)])
            })
        var body = ctrl.data().map(function (item,index) {
                return m("tr",[m("td", item)])
            })
        return m("table",[head,body]);        
    },
}

m.module(document.getElementById('container'), table); 
```
```language-coffeescript
table =
  data: [
    11
    10
    12
  ]
  header: ["item"]
  controller: ->
    @data = m.prop(table.data)
    @header = m.prop(table.header)
    return

  view: (ctrl) ->
    head = ctrl.header().map((item, index) ->
      m "tr", [m("th",
        class: "red"
      , item)]
    )
    body = ctrl.data().map((item, index) ->
      m "tr", [m("td", item)]
    )
    m "table", [
      head
      body
    ]

m.module document.getElementById("container"), table
```
[JSFiddle][10]

Not very exciting. Let me point out a couple of things.

I am using `m.prop()` on the controller properties. It's just a simple getter/setter utility. This is handy since if we decide to change the definition of a property, our code elsewhere will not be affected.

We are writing our html in javascript. Implementing flow control in javascript avoids the performance problems of `foreach, if` constructs in KnockoutJS. However, the designers on your team are probably not going to put up with having to use javascript. This problem can be alleviated somewhat by using React's [JSX][11] syntax [ported][12] to Mithril. In this post, I'll stick with plain javascript.

Sorting On Click
----------------

Let's sort the table when we click on the table header. But first let's modify our data to be more realistic.

``` language-javascript
var table = {
    state: {},
    data: [{
        value: 11
    }, {
        value: 10
    }, {
        value: 12
    }],
    header: [{
        display: "Value",
        sortBy: "value",
        sortType: "int"
    }],
    controller: function () {
        this.data = m.prop(table.data);
        this.header = m.prop(table.header);
    },
    view: function (ctrl) {
        var head = ctrl.header().map(function (item, index) {
            return m("tr", [m("th", {
                class: "red",
                    "data-sort-type": item.sortType,
                    "data-sort-by": item.sortBy
            }, item.display)])
        })
        var body = ctrl.data().map(function (item, index) {
            return m("tr", [m("td", item.value)])
        })
        return m("table", [head, body]);
    },
}

m.module(document.getElementById('container'), table);
```
``` language-coffeescript
table =
  state: {}
  data: [
    {
      value: 11
    }
    {
      value: 10
    }
    {
      value: 12
    }
  ]
  header: [
    display: "Value"
    sortBy: "value"
    sortType: "int"
  ]
  controller: ->
    @data = m.prop(table.data)
    @header = m.prop(table.header)
    return

  view: (ctrl) ->
    head = ctrl.header().map((item, index) ->
      m "tr", [m("th",
        class: "red"
        "data-sort-type": item.sortType
        "data-sort-by": item.sortBy
      , item.display)]
    )
    body = ctrl.data().map((item, index) ->
      m "tr", [m("td", item.value)]
    )
    m "table", [
      head
      body
    ]

m.module document.getElementById("container"), table
```
We have added `sortBy` and `sortType` properties to the table header. We will be keeping track of which column is sorted by putting those properties in the `state` property of the table. Our `data` property in the table is now a list of objects rather than primitives.

Rather than posting small code snippets here and there, I am going to go through the logic and then post the completed code. Start by adding onclick event handler `ctrl.handleTableClick` to the table element. We attach to the table itself rather than the individual headers because events in javascript propagate to the parent elements. In the handler function `ctrl.handleTableClick`, we can access the clicked html element through `event.target`. If the element clicked is a header, we then call `table.changeSortState`. This function updates the table state appropriately. It then calls the controller (which we pass in as a parameter) function `sortData`. Inside `sortData`, we access the table state to determine how to sort the data and then sort it appropriately. Once there is a change in controller data, Mithril will update our view (after the controller has finished running all of its code).

```language-javascript
var table = {
    state: {},
    data: [{
        value: 11
    }, {
        value: 10
    }, {
        value: 12
    }],
    header: [{
        display: "Value",
        sortBy: "value",
        sortType: "int"
    }],
    changeSortState: function (sortBy, sortType, ctrl) {
        if (table.state.sort === null || table.state.sort === undefined) {
            table.state.sort = {};
        }
        table.state.sort.sortBy = sortBy;
        table.state.sort.sortType = sortType;
        if (table.state.sort.sortDir === "asc") {
            table.state.sort.sortDir = "des";
        } else {
            table.state.sort.sortDir = "asc";
        }
        ctrl.sortData();
    },
    controller: function () {
        this.data = m.prop(table.data);
        this.header = m.prop(table.header);
        this.sortData = function () {
            var sortValues = {
                asc: 1,
                des: -1
            }
            var sortMult = sortValues[table.state.sort.sortDir]
            this.data().sort(function (a, b) {
                return sortMult * (a[table.state.sort.sortBy] - b[table.state.sort.sortBy])
            });
        }
        this.handleTableClick = function (e) {
            var sortType = e.target.getAttribute("data-sort-type");
            var sortBy = e.target.getAttribute("data-sort-by");
            if (sortBy && sortType) {
                table.changeSortState(sortBy, sortType, this);
            }
        }.bind(this);
    },
    view: function (ctrl) {
        var head = ctrl.header().map(function (item, index) {
            return m("tr", [m("th.clickable", {
                class: "red",
                    "data-sort-type": item.sortType,
                    "data-sort-by": item.sortBy
            }, item.display)])
        })
        var body = ctrl.data().map(function (item, index) {
            return m("tr", [m("td", item.value)])
        })
        return m("table", {
            onclick: ctrl.handleTableClick
        }, [head, body]);
    },
}

m.module(document.getElementById('container'), table);
```
``` language-coffeescript
table =
  state: {}
  data: [
    {
      value: 11
    }
    {
      value: 10
    }
    {
      value: 12
    }
  ]
  header: [
    display: "Value"
    sortBy: "value"
    sortType: "int"
  ]
  changeSortState: (sortBy, sortType, ctrl) ->
    table.state.sort = {}  if not table.state.sort?
    table.state.sort.sortBy = sortBy
    table.state.sort.sortType = sortType
    if table.state.sort.sortDir is "asc"
      table.state.sort.sortDir = "des"
    else
      table.state.sort.sortDir = "asc"
    ctrl.sortData()
    return

  controller: ->
    @data = m.prop(table.data)
    @header = m.prop(table.header)
    @sortData = ->
      sortValues =
        asc: 1
        des: -1

      sortMult = sortValues[table.state.sort.sortDir]
      @data().sort (a, b) ->
        sortMult * (a[table.state.sort.sortBy] - b[table.state.sort.sortBy])

      return

    @handleTableClick = ((e) ->
      sortType = e.target.getAttribute("data-sort-type")
      sortBy = e.target.getAttribute("data-sort-by")
      table.changeSortState(sortBy, sortType, this)  if sortBy and sortType
      return
    ).bind(this)
    return

  view: (ctrl) ->
    head = ctrl.header().map((item, index) ->
      m "tr", [m("th.clickable",
        class: "red"
        "data-sort-type": item.sortType
        "data-sort-by": item.sortBy
      , item.display)]
    )
    body = ctrl.data().map((item, index) ->
      m "tr", [m("td", item.value)]
    )
    m "table",
      onclick: ctrl.handleTableClick
    , [
      head
      body
    ]

m.module document.getElementById("container"), table
```
[JSFiddle][13]

In part 2, we will add more columns, initial sort, and random data.

[1]: http://knockoutjs.com/ "KnockoutJS"
[2]: https://facebook.github.io/react/ "React"
[3]: http://jlongster.com/Removing-User-Interface-Complexity,-or-Why-React-is-Awesome
[4]: http://www.ractivejs.org/ "RactiveJS"
[5]: https://github.com/Raynos/mercury "Mercury"
[6]: http://famo.us/ "Famous"
[7]: http://lhorie.github.io/mithril/ "Mithril"
[8]: http://lhorie.github.io/mithril/getting-started.html
[9]: http://lhorie.github.io/mithril-blog/vanilla-table-sorting.html
[10]: http://jsfiddle.net/jjk8bxeq/5/
[11]: http://facebook.github.io/react/docs/jsx-in-depth.html
[12]: https://github.com/insin/msx
[13]: http://jsfiddle.net/jjk8bxeq/9/