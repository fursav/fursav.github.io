---
title: "Mithril Sortable Table - Part 2"
about: "Introducing Mithril - Improved sortable table"
date: 2014-09-12
---

In [Part 1][1], we created a single column sortable table. In this post, we will add visiual feedback for sort state, implement initial sort, and add more columns.

Sort Indicator
--------------

I have refactored the code to be a little more clear. Let's start improving the table by making a visual distiction between sort states. Currently, the header class is just `red`. Let's replace that with a function that returns appropriate css class based on the table state.

``` language-javascript
this.getHeaderClasses = function (item) {
    if (table.state.sort.sortKey === item.key) {
        return table.state.sort.sortDir;
    }
    return "";
};
```

This function takes in an item we define in the `header` array of the table and returns a css class (`asc` or `des`) if the table is sorted by the key corresponding the header/column.

[JSFiddle][2]

Initial Sort
------------

Let's try adding initial sort. A quick glance at the code could lead us to believe that all we need to do is fill in `sortKey` and `sortDir` in the state of the table to have our table intially sorted. Unfortunately, that doesn't work. We need to add a `sortData()` call inside our controller. However, that's not a bad practice that could easily lead to problems down the road. So let's refactor our code so that we don't have to manually invoke the sort at all.

Let's get rid of `controller.sortData` function and all references to it. Next let's replace `controller.data = m.prop(table.data)` with a function

``` language-javascript
this.data = function () {
    var state = table.state.sort;
    var sortValues = {
        asc: 1,
        des: -1
    };
    var sortMult = sortValues[table.state.sort.sortDir];
    return table.data.sort(function (a, b) {
        aVal = a[state.sortKey];
        bVal = b[state.sortKey];
        // if aVal equals bVal
        result = 0;
        if (aVal > bVal)
            result = 1;
        else if (aVal < bVal)
            result = -1;
        return sortMult * result;
    });
};
```

Essentialy, we have merged the sorting functionality with the retrieval of the data. Now, whenever our state updates, our data will be immediately resorted and our view will be automatically updated.

[JSFiddle][3]

More Columns
------------

A single column table is not exactly a great achievement in web development. Once again by glancing at the code, we might think that in order to add more columns, we just need to add another item to the `header` and `data` lists of the table. Unfortunately, our view is structured to only present one column right now. Let's refactor `view.body`

``` language-javascript
var body = ctrl.data().map(function(item, index) {
    return m("tr", ctrl.header().map(function(header) {
        return m("td", item[header.key]);
    }));
});
```

Instead of manually defining which key we want to display in which position, we iterate over the table header and use the key that corresponds to the column. 

Now we are ready to add more data and columns. I added names to our data but you are obviously free to add anything you want. And happily, we don't have to modify our code for the sorting to work on the new column.

``` language-javascript
var table = {
    state: {
        sort: {
            sortKey: "value",
            sortDir: "des"
        }
    },
    data: [{
        name: "John Smith",
        value: 11
    }, {
        name: "James Henry",
        value: 10
    }, {
        name: "Sam Johnson",
        value: 12
    }],
    header: [{
        label: "Name",
        key: "name",
        sortType: "string"
    }, {
        label: "Value",
        key: "value",
        sortType: "int"
    }],
    changeSortState: function (sortKey, sortType) {
        if (table.state.sort === null || table.state.sort === undefined) {
            table.state.sort = {};
        }
        table.state.sort.sortKey = sortKey;
        table.state.sort.sortType = sortType;
        if (table.state.sort.sortDir === "asc") {
            table.state.sort.sortDir = "des";
        } else {
            table.state.sort.sortDir = "asc";
        }
    },
    controller: function () {
        this.data = function () {
            var state = table.state.sort;
            var sortValues = {
                asc: 1,
                des: -1
            };
            var sortMult = sortValues[table.state.sort.sortDir];
            return table.data.sort(function (a, b) {
                aVal = a[state.sortKey];
                bVal = b[state.sortKey];
                // if aVal equals bVal
                result = 0;
                if (aVal > bVal)
                    result = 1;
                else if (aVal < bVal)
                    result = -1;
                return sortMult * result;
            });
        };
        this.header = m.prop(table.header);
        this.handleTableClick = function (e) {
            var sortType = e.target.getAttribute("data-sort-type");
            var sortKey = e.target.getAttribute("data-sort-key");
            if (sortKey && sortType) {
                table.changeSortState(sortKey, sortType);
            }
        }.bind(this);
    },
    view: function (ctrl) {
        this.getHeaderClasses = function (item) {
            if (table.state.sort.sortKey === item.key) {
                return table.state.sort.sortDir;
            }
            return "";
        };
        var head = m("tr", ctrl.header().map(function (item, index) {
            return m("th.clickable", {
                class: this.getHeaderClasses(item),
                "data-sort-type": item.sortType,
                "data-sort-key": item.key
            }, item.label);
        }.bind(this)));
        var body = ctrl.data().map(function (item, index) {
            return m("tr", ctrl.header().map(function (header) {
                return m("td", item[header.key]);
            }));
        });
        return m("table", {
            onclick: ctrl.handleTableClick
        }, [head, body]);
    }
};

m.module(document.getElementById('container'), table);
```

[JSFiddle][4]

In Part 3, we will add a computed column and allow the user to randomize the data.


[1]: mithril-sort-1.html "Part 1"
[2]: http://jsfiddle.net/jjk8bxeq/20/
[3]: http://jsfiddle.net/jjk8bxeq/21/
[4]: http://jsfiddle.net/jjk8bxeq/23/