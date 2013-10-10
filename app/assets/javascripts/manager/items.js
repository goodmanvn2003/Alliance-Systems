var const_key_regex = /^[a-zA-Z0-9\-]+$/i;

/*------------*/
var tplVersionedCurrent = "<i class=\"icon-check\"></i>&nbsp;current";
var tplVersioned = "<i class=\"icon-exclamation-sign\"></i>&nbsp;" // version is put after this
var currentTab = "";
// Code compare
function initUI(panes, value, orig1, orig2, hilight) {
    if (value == null) return;
    var target = document.getElementById("compareView");
    target.innerHTML = "";
    var dv = CodeMirror.MergeView(target, {
        value: value,
        origLeft: panes == 3 ? orig1 : null,
        orig: orig2,
        lineNumbers: false,
        mode: "text/html",
        highlightDifferences: hilight
    });
}
//
function changeVersionToCurrent(elem){
    $(elem).attr("data-original-title", "current").tooltip("fixTitle");
    $(elem).attr("data-time","current");
}

function changeVersionToVersion(elem, datetimeObj){
    var datetime = new Date(Date.parse(datetimeObj));
    $(elem).attr("data-original-title", datetime.toLocaleString() + "(click to switch to current)").tooltip("fixTitle");
    $(elem).attr("data-time", datetimeObj);
}

function getInfoForPageEdit(id, elem)
{
    var category = $("#myTab li.active a:first").text();

    $.get("/manager/s/i/"+id,
        function(response) {
            if (response != null && response != undefined)
            {
                if (category == "Labels")
                    $(elem).val(response.value.trim());
                else if (category == "Articles")
                {
                    $(elem).val(response.value.trim());
                    $(elem).data('wysihtml5').editor.setValue(response.value.trim());
                }
                // $(elem).trigger("change");
                // Messenger().post("item's content is updated to current state");
            } else
            {
            }
        }).error(function(){
            Messenger().post("Cannot contact server!");
        });
}

// GET HISTORY
// Generic get item history method
function getItemHistory(id, hElem, offset)
{
    var elem = $("#" + hElem);

    $.getJSON("/manager/h/items/" + id + "?offset=" + offset, function(response){
        if (response.status == "success")
        {
            var data = response.data;
            elem.find("li:not(:first)").remove();

            $($($(elem).parent()).find("div:first")).show();
            $($($(elem).parent()).find(".historyPage").first()).show();
            $($($(elem).parent()).find(".historyPage").first()).text(response.nav.current + "/" + response.nav.max);

            if ( response.nav.max == 0 )
            {
                $($($(elem).parent()).find(".historyNext").first()).hide();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
                $($($(elem).parent()).find(".historyPage").first()).hide();
            }
            else if ( response.nav.max == 1 )
            {
                $($($(elem).parent()).find(".historyNext").first()).hide();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
            }
            else if ( response.nav.max > 1 && response.nav.current == 1  && response.nav.current < response.nav.max)
            {
                $($($(elem).parent()).find(".historyNext").first()).show();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
            }
            else if ( response.nav.max > 1 && response.nav.current > 1  && response.nav.current < response.nav.max)
            {
                $($($(elem).parent()).find(".historyNext").first()).show();
                $($($(elem).parent()).find(".historyPrev").first()).show();
            } else if ( response.nav.max > 1 && response.nav.current == response.nav.max)
            {
                $($($(elem).parent()).find(".historyNext").first()).hide();
                $($($(elem).parent()).find(".historyPrev").first()).show();
            }

            // Add Current Marker
            var item = $("<li style=\"font-size:12px;\"><i class=\"icon-pencil\"></i>&nbsp;<span></span>&nbsp<span></span></li>");

            if (data.length > 0)
            {
                for (var i = 0; i < data.length; i++)
                {
                    var item = $("<li style=\"font-size:12px;\"><i class=\"icon-pencil\"></i>&nbsp;<span></span>&nbsp<span></span></li>");

                    $(item.find("i:first")).attr("data-time",data[i].created_at);
                    $(item.find("i:first")).css("cursor","pointer");
                    $(item.find("span:first")).text(data[i].whodunnit);
                    $(item.find("span:eq(1)")).text("(" + $.timeago(data[i].created_at) + ")");
                    $(elem.find("li:first-child")).after(item);

                    $(item.find("i:first")).on("click", function(e){
                        e.stopPropagation();

                        var timeData = $(this).attr("data-time");
                        $("#codeCompareModal").attr("data-time", timeData);
                        // console.log(pElem);
                        $("#codeCompareModal").attr("data-id", id);

                        $('#codeCompareModal').width("780");
                        $('#codeCompareModal').css("margin-left","-390px");
                        $("#codeCompareModal").modal("show");
                    });
                }
            }
            else
            {
                elem.append("<li style=\"font-size:12px;\">nothing found</li>");
                $($($(elem).parent()).find(".historyNext").first()).hide();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
                $($($(elem).parent()).find(".historyPage").first()).hide();
            }

        }
        else
        {
            elem.find("li:not(:first)").remove();
            elem.append("<li style=\"font-size:12px;\">unavailable...</li>");
            $($($(elem).parent()).find(".historyNext").first()).hide();
            $($($(elem).parent()).find(".historyPrev").first()).hide();
            $($($(elem).parent()).find(".historyPage").first()).hide();
            //Messenger().post("unable to retrieve item history");
        }

    }).error(function(){
            elem.find("li:not(:first)").remove();
            elem.append("<li style=\"font-size:12px;\">unavailable...</li>");
            $($($(elem).parent()).find(".historyNext").first()).hide();
            $($($(elem).parent()).find(".historyPrev").first()).hide();
            $($($(elem).parent()).find(".historyPage").first()).hide();
            //Messenger().post("unable to contact server");
        });
}

function updatePageHistory(offset)
{
    var elems = null, elemId = null;
    var category = $("#myTab li.active a:first").text();

    if (category == "Labels")
    {
        elemId = "historyList_labels";
        elems = $("#labelsTableBody tr.success");
    }
    else if (category == "Articles")
    {
        elemId = "historyList_articles"
        elems = $("#articlesTableBody tr.success");
    }

    if (elems.length == 1)
    {
        var id = $($(elems.first()).find("td:first")).attr("data-id");

        getItemHistory(id, elemId, offset);
    } else
    {
        if (category == "Labels")
        {
            $($("#historyList_labels").find("li:not(:first)")).remove();
            $($("#historyList_articles").next("div")).hide();
        }
        else if (category == "Articles")
        {
            $($("#historyList_articles").find("li:not(:first)")).remove();
            $($("#historyList_articles").next("div")).hide();
        }
    }
}
/*------------*/

function refreshLocales(type){
    $.getJSON("/manager/s/items/list/locale", function(response){
        if (response.length > 0) {
            var languageOptions = "";

            for (var l = 0; l < response.length; l++)
            {
                languageOptions += "<option value='" + response[l].id.toString() + "'>" + response[l].key.trim() + "</option>";
            }

            $(".selectLanguage").html(languageOptions);

            if (type == "labels") refreshLabelsTable($("#labelsLocale").val());
            else if (type == "articles") refreshArticlesTable($("#articlesLocale").val());
        } else
            $(".selectLanguage").html("<option value='-1'>No items</option>");

    }).error(function(){
        $(".selectLanguage").html("<option>Error when retrieving</option>");
    });
}

function refreshLabelsTable(locale){
    $("#labelsTabLoadingText").fadeIn("fast");
    $("#labelsTable tBody:first > tr:gt(1)").remove();

    $.getJSON("/manager/s/items/list/rassoc/" + locale + "/label",function (data) {
        if (data.length > 0) {
            for (var i = 0; i < data.length; i++) {
                var cloned = $("#labelsItemDummy").clone();
                $($(cloned).find("td")[0]).attr("data-id", data[i].id);
                $($(cloned).find("td")[0]).text((i + 1).toString());
                $($($(cloned).find("td")[1]).find("a:eq(1)")).attr("data-time", "current");
                $($($(cloned).find("td")[1]).find("a:eq(1)")).tooltip({
                    "title": "current"
                });
                $($($(cloned).find("td")[2]).find("input[type=text]:first")).val(data[i].key);
                $($($(cloned).find("td")[3]).find("input[type=text]:first")).val(data[i].value);

                $(cloned).removeAttr("id");
                $(cloned).removeAttr("style");

                $("#labelsTable tBody:first").append(cloned);
            }
        } else {
        }

        $("#labelsTabLoadingText").fadeOut("fast");
    }).error(function () {
            Messenger().post("Unable to retrieve a list of labels!");
            $("#labelsTabLoadingText").fadeOut("fast");
        });
}

function refreshArticlesTable(locale){
    $("#articlesTabLoadingText").fadeIn("fast");
    $("#articlesTable tBody:first > tr:gt(1)").remove();

    $.getJSON("/manager/s/items/list/rassoc/" + locale + "/article",function (data) {

        if (data.length > 0) {

            for (var i = 0; i < data.length; i++) {
                var cloned = $("#articlesItemDummy").clone();
                var cloned_textarea;
                $($(cloned).find("td")[0]).attr("data-id", data[i].id);
                $($(cloned).find("td")[0]).text((i + 1).toString());
                $($($(cloned).find("td")[1]).find("a:eq(1)")).attr("data-time", "current");
                $($($(cloned).find("td")[1]).find("a:eq(1)")).tooltip({
                    "title": "current"
                });
                $($($(cloned).find("td")[2]).find("input[type=text]:first")).val(data[i].key);
                cloned_textarea = $($($(cloned).find("td")[3]).find("textarea")[0]);
                $(cloned_textarea).val(data[i].value);

                $(cloned).removeAttr("id");
                $(cloned).removeAttr("style");

                $("#articlesTable tBody:first").append(cloned);

                $(cloned_textarea).wysihtml5({
                    "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
                    "emphasis": true, //Italics, bold, etc. Default true
                    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
                    "html": true, //Button which allows you to edit the generated HTML. Default false
                    "link": true, //Button to insert a link. Default true
                    "image": true, //Button to insert an image. Default true,
                    "color": true, //Button to change color of font
                    "events": {
                        "load": function () {

                        },
                        "focus": function() {
                            var textarea = $(this.textarea.element);
                            var parent = $($(textarea.parents("tr:first")));
                            $(".articlesItem").removeClass("success");
                            $(parent).addClass("success");

                            getItemHistory($($(parent).find("td:first")).attr("data-id"), "historyList_articles", 0);
                            $($("#historyList_articles").parent()).attr("data-page","0");
                        },
                        "change": function () {
                            var textarea = $(this.textarea.element);
                            var parent = $($(textarea.parents("tr:first")));

                            var updateId = $(parent.find("td:first")).attr("data-id");
                            var updateData = textarea.val();
                            var updateObj = {
                                "value": updateData
                            }
                            var time = $(parent.find("td:eq(1) a:eq(1)")).attr("data-time");

                            $.ajax({
                                url: "/manager/configurations/" + updateId,
                                type: "PUT",
                                cache: false,
                                data: {
                                    "id": updateId,
                                    "data": updateObj,
                                    "time": time
                                },
                                error: function () {
                                    Messenger().post("Unable to update article!");
                                },
                                success: function (response) {
                                    if (response.status == "success") {
                                        if (response.extra != null)
                                        {
                                            if (response.extra.compliance_status == "saved_published")
                                                Messenger().post("content has just been updated and published");
                                            else if (response.extra.compliance_status == "saved")
                                                Messenger().post("content has just been updated");
                                        } else
                                            Messenger().post("Content has just been updated!");
                                    } else {
                                        if (response.message == "own-change")
                                        {
                                            Messenger().post("content has just been updated but your change is pending for review and publishment");
                                        } else
                                        {
                                            Messenger().post("Failure - reason: " + response.message);
                                        }
                                    }

                                    getItemHistory(updateId, "historyList_articles", 0);
                                    $($("#historyList_articles").parent()).attr("data-page","0");
                                }
                            });
                        }
                    }
                });
            }
        } else {

        }

        $("#articlesTabLoadingText").fadeOut("fast");
    }).error(function () {
            Messenger().post("Unable to retrieve a list of labels!");
            $("#articlesTabLoadingText").fadeOut("fast");
        });
}

function deleteLabels(object)
{
    var deleteId = $(object).attr("data-id");

    $.ajax({
        url: "/manager/configurations/" + deleteId,
        type: "DELETE",
        cache: false,
        error: function(){
            Messenger().post("Unable to reach server");
        },
        success: function(response){
            if (response.status == "success")
            {
                Messenger().post("Label has just been deleted");

                refreshLabelsTable($("#labelsLocale").val());
            } else
            {
                Messenger().post("Unable to delete label");
            }
        }
    })
}

function deleteArticles(object)
{
    var deleteId = $(object).attr("data-id");

    $.ajax({
        url: "/manager/configurations/" + deleteId,
        type: "DELETE",
        cache: false,
        error: function(){
            Messenger().post("Unable to reach server");
        },
        success: function(response){
            if (response.status == "success")
            {
                Messenger().post("Article has just been deleted");

                refreshArticlesTable($("#articlesLocale").val());
            } else
            {
                Messenger().post("Unable to delete article");
            }
        }
    })
}

$(function () {

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    var articleWysiwyg = $("#newArticlesContentTxt").wysihtml5({
        "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
        "emphasis": true, //Italics, bold, etc. Default true
        "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
        "html": true, //Button which allows you to edit the generated HTML. Default false
        "link": true, //Button to insert a link. Default true
        "image": true, //Button to insert an image. Default true,
        "color": true //Button to change color of font
    });

    $("#myTab a[data-toggle=\"tab\"]").on("shown", function (e) {
        var targetId = $(e.target).attr("href").replace("#", "");
        curTab = targetId;

        switch (curTab) {
            case "labels":
                refreshLocales("labels");
                break;
            case "articles":
                refreshLocales("articles");
                break;
            default:

        }
    });

    $("#labelsTable tbody:first").on("change", "td[data-modify-flag=checked] input[type=text]", function (e) {
        e.stopPropagation();

        var parent = $($(this).parents("tr:first"));

        var updateId = $($(parent).find("td:first")).attr("data-id");
        var updateObj = {};

        var updateCol = $($(this).parents("td:first")).index();
        if (updateCol == 2)
            updateObj = {
                "key": $(this).val()
            };
        else if (updateCol == 3)
            updateObj = {
                "value": $(this).val()
            }
        var time = $($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)")).attr("data-time");

        $.ajax({
            url: "/manager/configurations/" + updateId,
            type: "PUT",
            cache: false,
            data: {
                "id": updateId,
                "data": updateObj,
                "time": time
            },
            error: function () {
                Messenger().post("Unable to update label!");
            },
            success: function (response) {
                if (response.status == "success") {
                    if (response.extra != null)
                    {
                        if (response.extra.compliance_status == "saved_published")
                            Messenger().post("content has just been updated and published");
                        else if (response.extra.compliance_status == "saved")
                            Messenger().post("content has just been updated");
                    } else
                        Messenger().post("Content has just been updated!");
                } else {
                    if (response.message == "own-change")
                    {
                        Messenger().post("content has just been updated but your change is pending for review and publishment");
                    } else
                    {
                        Messenger().post("Failure - reason: " + response.message);
                    }
                }

                getItemHistory(updateId, "historyList_labels", 0);
                $($("#historyList_labels").parent()).attr("data-page","0");
            }
        });
    });

    $("#articlesTable tbody:first").on("change", "td[data-modify-flag=checked] input[type=text]", function (e) {
        e.stopPropagation();

        var parent = $($(this).parents("tr:first"));

        var updateId = $($(parent).find("td:first")).attr("data-id");
        var updateObj = {
            "key": $(this).val()
        };
        var time = $($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)")).attr("data-time");

        $.ajax({
            url: "/manager/configurations/" + updateId,
            type: "PUT",
            cache: false,
            data: {
                "id": updateId,
                "data": updateObj,
                "time": time
            },
            error: function () {
                Messenger().post("Unable to update article!");
            },
            success: function (response) {
                if (response.status == "success") {
                    if (response.extra != null)
                    {
                        if (response.extra.compliance_status == "saved_published")
                            Messenger().post("content has just been updated and published");
                        else if (response.extra.compliance_status == "saved")
                            Messenger().post("content has just been updated");
                    } else
                        Messenger().post("Content has just been updated!");
                } else {
                    if (response.message == "own-change")
                    {
                        Messenger().post("content has just been updated but your change is pending for review and publishment");
                    } else
                    {
                        Messenger().post("Failure - reason: " + response.message);
                    }
                }

                getItemHistory(updateId, "historyList_articles", 0);
                $($("#historyList_articles").parent()).attr("data-page","0");
            }
        });
    });

    $("#labelsTable tbody:first").on("click", ".labelDelete", function(){
        var parent = $(this).parents("tr:first");

        $("#labelDeleteButton").attr("data-id", $($(parent).find("td:first")).attr("data-id"));
    });

    $("#articlesTable tbody:first").on("click", ".articleDelete", function(){
        var parent = $(this).parents("tr:first");

        $("#articleDeleteButton").attr("data-id", $($(parent).find("td:first")).attr("data-id"));
    });

    $("#labelsTable tbody:first").on("click", ".labelVersionInfo", function(){
        var id = $($($(this).parents("tr:first")).find("td:first")).attr("data-id");

        getInfoForPageEdit(id, $($(this).parents("tr:first")).find("td:eq(3) input[type=text]"));
        changeVersionToCurrent($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)"));
    });

    $("#labelsTable tbody:first").on("click", ".labelOverridingSave", function(){
        $($($(this).parents("tr:first")).find("td:eq(3) input[type=text]")).trigger("change");
        changeVersionToCurrent($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)"));
    });

    $("#articlesTable tbody:first").on("click", ".articleVersionInfo", function(){
        var id = $($($(this).parents("tr:first")).find("td:first")).attr("data-id");

        getInfoForPageEdit(id, $($(this).parents("tr:first")).find("td:eq(3) textarea:first"));
        changeVersionToCurrent($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)"));
    });

    $("#articlesTable tbody:first").on("click", ".articleOverridingSave", function(){
        $($($(this).parents("tr:first")).find("td:eq(3) textarea:first")).data("wysihtml5").editor.fire("change");
        changeVersionToCurrent($($(this).parents("tr:first")).find("td:eq(1) a:eq(1)"));
    });

    $("#aNewLabels").on("click", function(){
        var createKey = $("#newLabelsNameTxt").val(),
            createValue = $("#newLabelsContentTxt").val(),
            createLocale = $("#labelsLocale").val();

        if (createKey.length > 0 && createValue.length > 0 && createLocale != "-1")
        {
            if (const_key_regex.test(createKey)) {
                $.post("/manager/configurations", {
                    "key" : createKey.trim(),
                    "value" : createValue.trim(),
                    "mime" : "text/plain",
                    "cat" : "label",
                    "type" : "locale",
                    "locale" : createLocale
                }, function(response){
                    if (response.status == "success")
                    {
                        $("#newLabelsNameTxt").val("");
                        $("#newLabelsContentTxt").val("");

                        refreshLabelsTable($("#labelsLocale").val());

                        Messenger().post("Label has just been created");
                    }
                    else
                        Messenger().post(response.message);
                }).error(function(){
                    Messenger().post("Unable to reach server");
                });
            } else
                Messenger().post("Key format is not valid");
        } else
            Messenger().post("Key and value of label must not be empty or no language was specified!")
    });

    $("#aNewArticles").on("click", function(){
        var createKey = $("#newArticlesNameTxt").val(),
            createValue = $("#newArticlesContentTxt").val(),
            createLocale = $("#articlesLocale").val();

        if (createKey.length > 0 && createValue.length > 0 && createLocale != "-1")
        {

            if (const_key_regex.test(createKey))
            {
                $.post("/manager/configurations", {
                "key" : createKey.trim(),
                "value" : createValue.trim(),
                "mime" : "text/html",
                "cat" : "article",
                "type" : "locale",
                "locale" : createLocale
            }, function(response){
                if (response.status == "success")
                {
                    $("#newArticlesNameTxt").val("");
                    articleWysiwyg.data('wysihtml5').editor.setValue("");

                    refreshArticlesTable($("#articlesLocale").val());

                    Messenger().post("Article has just been created");
                }
                else
                    Messenger().post(response.message);
            }).error(function(){
                    Messenger().post("Unable to reach server");
                });
            } else
                Messenger().post("Key format is not valid");
        } else
            Messenger().post("Key and value of label must not be empty or no language was specified!")
    });

    $("#labelsLocale").on("change", function(e){
        e.stopPropagation();
        var locale = $(this).val();

        refreshLabelsTable(locale);
    });

    $("#articlesLocale").on("change", function(e){
        e.stopPropagation();
        var locale = $(this).val();

        refreshArticlesTable(locale);
    });

    $("#txtFilterLabel").on("keyup", function(e){
        var query = $(this).val();

        var trs = $($("#labelsTable tbody").first()).find("tr").slice(2);

        $(trs).stop().fadeOut("fast");
        for (var i = 0; i < trs.length; i++)
        {
            var type = $($($(trs[i]).find("td")[2]).find("div").first()).find("input[type=text]")

            if ($(type).val().indexOf(query) >= 0)
            {
                $(trs[i]).fadeIn("fast");
            }
        }
    });

    $("#txtFilterArticle").on("keyup", function(e){
        var query = $(this).val();

        var trs = $($("#articlesTable tbody").first()).find("tr").slice(2);

        $(trs).stop().fadeOut("fast");
        for (var i = 0; i < trs.length; i++)
        {
            var type = $($($(trs[i]).find("td")[2]).find("div").first()).find("input[type=text]")

            if ($(type).val().indexOf(query) >= 0)
            {
                $(trs[i]).fadeIn("fast");
            }
        }
    });

    $("#labelsTableBody").on("click", ".labelsItem", function(e){
        e.stopPropagation();

        var id = $($(this).find("td:first")).attr("data-id");
        $(".labelsItem").removeClass("success");
        $(this).addClass("success");

        getItemHistory(id, "historyList_labels", 0);
        $($("#historyList_labels").parent()).attr("data-page","0");
    });

    $("#articlesTableBody").on("click", ".articlesItem", function(e){
        e.stopPropagation();

        var id = $($(this).find("td:first")).attr("data-id");
        var tabItem = $($("#myTab li.active:first").find("a:first")).text();
        $(".articlesItem").removeClass("success");
        $(this).addClass("success");

        getItemHistory(id, "historyList_articles", 0);
        $($("#historyList_labels").parent()).attr("data-page","0");
    });

    /* Code Compare */

    $("#codeCompareModal").on("shown", function(){
        var id = $(this).attr("data-id"),
            datetime = $(this).attr("data-time"),
            $this = $(this);

        var category = $("#myTab li.active a:first").text();
        var datetimeObj = new Date(Date.parse(datetime));
        $($this.find("#codeCompareModalOtherVersion")).text(datetimeObj.toLocaleString());
        $.getJSON("/manager/h/item/" + id + "/" + datetime, function(response){
            if (response.status == "success")
            {
                $("#codeCompareModalBody").show();
                $("#codeCompareModalRevertBtn").attr("data-time", datetime);
                $("#codeCompareModalRevertBtn").attr("data-id", id);
                $("#codeCompareModalRevertBtn").attr("data-editor", $this.attr("data-editor"));
                $.data(document.getElementById("codeCompareModalRevertBtn"), "value", response.data.value);

                var editorValue = "";
                if (category == "Labels") {
                    editorValue = $($($(".labelsItem.success").first()).find("td:eq(3) input[type=text]")).val();
                }
                else if (category == "Articles") {
                    editorValue = $($($(".articlesItem.success").first()).find("td:eq(3) textarea:first")).val();
                }

                initUI(2, editorValue, '123', response.data.value, true);
            }
            else
            {
                Messenger().post("unable to get archived data");
            }
        }).error(function(){
                Messenger().post("unable to contact server");
            });
    });

    $("#codeCompareModal").on("hidden", function(){
        $($(this).find("#codeCompareModalBody")).hide();
        $($(this).find("#codeCompareModalRevertBtn")).removeAttr("data-time");
        $($(this).find("#codeCompareModalRevertBtn")).removeAttr("data-id");
        $($(this).find("#codeCompareModalRevertBtn")).removeAttr("data-editor");
    });

    $("#codeCompareModalRevertBtn").on("click", function(){
        var revertedValue = $.data(document.getElementById("codeCompareModalRevertBtn"), "value");
        $("#codeCompareModal").modal("hide");

        // Parse version number
        var datetimeObj = new Date(Date.parse($(this).attr("data-time")));
        var category = $("#myTab li.active a:first").text();

        if (category == "Labels") {
            $($($(".labelsItem.success").first()).find("td:eq(3) input[type=text]")).val(revertedValue);
            // $($($(".labelsItem.success").first()).find("td:eq(3) input[type=text]")).trigger("change");
        } else if (category == "Articles")
        {
            $($($(".articlesItem.success").first()).find("td:eq(3) textarea:first")).val(revertedValue);
            $($($(".articlesItem.success").first()).find("td:eq(3) textarea:first")).data("wysihtml5").editor.setValue(revertedValue);
            // $($($(".articlesItem.success").first()).find("td:eq(3) textarea:first")).data("wysihtml5").editor.fire("change");
        }

        if (category == "Labels")
            changeVersionToVersion($($($(".labelsItem.success").first()).find("td:eq(1) a:eq(1)")), $(this).attr("data-time"));
        else if (category == "Articles")
            changeVersionToVersion($($($(".articlesItem.success").first()).find("td:eq(1) a:eq(1)")), $(this).attr("data-time"));
    });

    $(".historyNext #historyListNext").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) + 5));
        updatePageHistory(parseInt(page) + 5);
    });

    $(".historyPrev #historyListPrev").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) - 5));
        updatePageHistory(parseInt(page) - 5);
    });

    /* */

    $(".selectLanguage").on("change", function(e){
        var category = $("#myTab li.active a:first").text();
        if (category == "Labels")
        {
            $("#historyList_labels li:not(:first)").remove();
            $($("#historyList_labels").next("div")).hide();
        } else if (category == "Articles")
        {
            $("#historyList_articles li:not(:first)").remove();
            $($("#historyList_articles").next("div")).hide();
        }
    });

    $("#myTab").on("shown", function(e){
        $("#historyList_labels li:not(:first)").remove();
        $($("#historyList_labels").next("div:first")).hide();
        $("#historyList_articles li:not(:first)").remove();
        $($("#historyList_articles").next("div:first")).hide();
    });
})
