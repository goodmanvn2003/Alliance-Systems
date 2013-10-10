var const_key_regex = /^[a-zA-Z0-9\-]+$/i;
var mixedMode = {
    name: "htmlmixed",
    scriptTypes: [
        {matches: /\/x-handlebars-template|\/x-mustache/i,
            mode: null}
    ]
};
var tplMetaEditor, tplHtmlEditor, tplElementEditor, tplRubyEditor,
    currentEditor;
CodeMirror.commands.autocomplete = function (cm) {
    CodeMirror.showHint(cm, CodeMirror.hint.html);
}
tplMetaEditor = CodeMirror.fromTextArea(document.getElementById("tplMetaCode"), {
    mode: "text/xml",
    tabMode: "indent",
    extraKeys: {
        "Ctrl-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") < 0) {
                $("#metaSaveBtn").text("saving...");
                data = $("#metaSaveBtn").attr("metatagdata-attr");

                if (data != null && data != undefined && data != "")
                    saveMetatag($("#metaSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    saveMetatag($("#metaSaveBtn"), data);
                }
            }
        },
        "Cmd-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") >= 0) {
                $("#metaSaveBtn").text("saving...");
                data = $("#metaSaveBtn").attr("metatagdata-attr");

                if (data != null && data != undefined && data != "")
                    saveMetatag($("#metaSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    saveMetatag($("#metaSaveBtn"), data);
                }
            }
        }
    },
    lineNumbers: true
});
tplHtmlEditor = CodeMirror.fromTextArea(document.getElementById("tplHtmlCode"), {
    mode: mixedMode,
    tabMode: "indent",
    extraKeys: {"Ctrl-Space": "autocomplete",
        "Ctrl-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") < 0) {
                $("#templateSaveBtn").text("saving...");
                data = $("#templateSaveBtn").attr("tpldata-attr");

                if (data != null && data != undefined && data != "")
                    saveTemplate($("#templateSaveBtn"), data);
                else {
                    //alert("Erm! Dat template doesn't exist!");
                    Messenger().post("Erm! Dat template doesn't exist!");
                    $("#templateSaveBtn").text("save");
                }
            }
        },
        "Cmd-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") >= 0) {
                $("#templateSaveBtn").text("saving...");
                data = $("#templateSaveBtn").attr("tpldata-attr");

                if (data != null && data != undefined && data != "")
                    saveTemplate($("#templateSaveBtn"), data);
                else {
                    //alert("Erm! Dat template doesn't exist!");
                    Messenger().post("Erm! Dat template doesn't exist!");
                    $("#templateSaveBtn").text("save");
                }
            }
        }
    },
    lineNumbers: true
});
tplElementEditor = CodeMirror.fromTextArea(document.getElementById("tplElementHtmlCode"), {
    mode: mixedMode,
    tabMode: "indent",
    extraKeys: {"Ctrl-Space": "autocomplete",
        "Ctrl-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") < 0) {
                $("#elementSaveBtn").text("saving...");
                data = $("#elementSaveBtn").attr("tpldata-attr");

                if (data != null && data != undefined && data != "")
                    savePlaceholder($("#elementSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    savePlaceholder($("#elementSaveBtn"), data);
                }
            }
        },
        "Cmd-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") >= 0) {
                $("#elementSaveBtn").text("saving...");
                data = $("#elementSaveBtn").attr("tpldata-attr");

                if (data != null && data != undefined && data != "")
                    savePlaceholder($("#elementSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    savePlaceholder($("#elementSaveBtn"), data);
                }
            }
        }
    },
    lineNumbers: true
});
tplRubyEditor = CodeMirror.fromTextArea(document.getElementById("tplScriptRubyCode"), {
    mode: "text/x-ruby",
    tabMode: "indent",
    extraKeys: {
        "Ctrl-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") < 0) {
                $("#scriptSaveBtn").text("saving...");
                data = $("#scriptSaveBtn").attr("scriptdata-attr");

                if (data != null && data != undefined && data != "")
                    saveScript($("#scriptSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    saveScript($("#scriptSaveBtn"), data);
                }
            }
        },
        "Cmd-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") >= 0) {
                $("#scriptSaveBtn").text("saving...");
                data = $("#scriptSaveBtn").attr("scriptdata-attr");

                if (data != null && data != undefined && data != "")
                    saveScript($("#scriptSaveBtn"), data);
                else {
                    Messenger().post("Erm! Dat element doesn't exist!");
                    saveScript($("#scriptSaveBtn"), data);
                }
            }
        }
    },
    lineNumbers: true
});

/*------------*/
var tplVersionedCurrent = "<i class=\"icon-check\"></i>&nbsp;current";
var tplVersioned = "<i class=\"icon-exclamation-sign\"></i>&nbsp;" // version is put after this
var currentVersionStatusElemId = "";
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
    $(elem).html(tplVersionedCurrent);
    $(elem).attr("data-time","current");
    $($($(elem).parent()).find("#switchToCurrentPage")).hide();
}

function changeVersionToVersion(elem, datetimeObj){
    var datetime = new Date(Date.parse(datetimeObj));
    $(elem).html(tplVersioned + datetime.toLocaleString());
    $(elem).attr("data-time", datetimeObj);
    $($($(elem).parent()).find("#switchToCurrentPage")).show();

    $($($(elem).parent()).find("#switchToCurrentPage")).on("click", function(){
        getInfoForPageEdit();
        changeVersionToCurrent($("#" + currentVersionStatusElemId));
    });
}

function getInfoForPageEdit()
{
    $("#overlay").fadeIn("fast");
    $.get("/manager/s/i/"+$($($("#elementsList li.active").first()).find("a").first()).attr("data-id"),
        function(response) {
            if (response != null && response != undefined)
            {
                currentEditor.setValue(response.value.trim());
                $("#overlay").fadeOut("fast");
            } else
            {
                $("#overlay").fadeOut("fast");
            }
        }).error(function(){
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        });
}

// GET HISTORY
// Generic get item history method
function getItemHistory(id, pElem, offset)
{
    var elem = $("#historyList");

    $.getJSON("/manager/h/items/" + id + "?offset=" + offset, function(response){
        if (response.status == "success")
        {
            var data = response.data;
            elem.find("li:not(:first)").remove();

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
                        $("#codeCompareModal").attr("data-id", $($($("#" + pElem + " li.active").first()).find("a").first()).attr("data-id"));
                        $("#codeCompareModal").attr("data-editor", pElem);

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

function updatePageHistory(listElemId,offset)
{
    var elems = $("#" + listElemId + " li.active");

    if (elems.length == 1)
    {
        var id = $($(elems.first()).find("a:first")).attr("data-id");

        getItemHistory(id, listElemId, offset);
    } else
    {
        $($("#historyList").find("li:not(:first)")).remove();
        $($($("#pageList").parent().find("#historyList:first")).next("div")).hide();
    }
}
/*------------*/

// Code Cleanup
function getSelectedRange(lEditor) {
    return { from: lEditor.getCursor(true), to: lEditor.getCursor(false) };
}

function autoFormatSelection(lEditor) {
    var range = getSelectedRange(lEditor);
    lEditor.autoFormatRange(range.from, range.to);
}
//

function getPlaceholderContent(elem, query){
    // This is an internal method
    // Get contents through AJAX
    currentVersionStatusElemId = "versionNumberPage_placeholder"
    $.get("/manager/s/g/" + query + "/placeholder",function (response) {
        $("#overlay").fadeOut("fast");
        if (response.value != undefined && response.id != undefined) {
            $("#element").fadeIn(1, function () {
                /**/
                tplElementEditor.setValue(response.value)
                tplElementEditor.setSize("auto", $(window).height() - 168)
            });

            $("#elementSaveBtn").attr("tpldata-attr", response.id);
            $("#elementSaveBtn").attr("pldata-attr", query);
            $("#elementSaveBtn").attr("tplname-attr", $(elem).attr("data-attr"));

            $("#" + currentVersionStatusElemId).show();
            getItemHistory(response.id,"placeholderList", 0);
            $("#versionNumberPage_placeholder").attr("data-time", "current");
            changeVersionToCurrent($("#" + currentVersionStatusElemId));
            currentEditor = tplElementEditor;
        } else {
            $("#element").fadeIn(1, function () {
                /**/
                tplElementEditor.setValue("");
                tplElementEditor.setSize("auto", $(window).height() - 168);
            });

            $("#elementSaveBtn").removeAttr("tpldata-attr");
            $("#elementSaveBtn").attr("pldata-attr", query);
            $("#elementSaveBtn").attr("tplname-attr", $(elem).attr("data-attr"));
        }

    }).error(function () {
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        });
}

function showContent(elem, query, type) {
    $(".elementItem").hide();
    $(".historyWidget").attr("data-page","0");
    console.log($(".historyWidget").attr("data-page", "0"));

    switch (type) {
        case "meta":
            $(".listItemMeta").removeClass("active");
            $(".listItemElement").removeClass("active");
            $(".listItemTemplate").removeClass("active");
            $(".listItemScript").removeClass("active");
            $("#meta").removeClass("hidden");
            $($(elem).parent()).addClass("active");
            currentVersionStatusElemId = "versionNumberPage_meta"

            $("#overlay").fadeIn("fast");
            $("#" + currentVersionStatusElemId).hide();
            $("#meta").fadeIn(1, function () {
                $.get("/manager/s/g/" + query + "/meta",function (response) {
                    tplMetaEditor.setValue(response.value);
                    tplMetaEditor.setSize("auto", $(window).height() - 128);

                    // Get history if any
                    getItemHistory(response.id,"metatagList", 0);
                    $("#" + currentVersionStatusElemId).attr("data-time", "current");
                    changeVersionToCurrent($("#" + currentVersionStatusElemId));
                    currentEditor = tplMetaEditor;

                    $("#metaSaveBtn").attr("metatagdata-attr", response.id);
                    $("#overlay").fadeOut("fast");
                    $("#" + currentVersionStatusElemId).show();
                }).error(function () {
                        Messenger().post("Cannot contact server!");
                        $("#overlay").fadeOut("fast");
                    });
            });
            break;
        case "element":
            $(".listItemMeta").removeClass("active");
            $(".listItemElement").removeClass("active");
            $(".listItemTemplate").removeClass("active");
            $(".listItemScript").removeClass("active");
            $("#element").removeClass("hidden");
            $($(elem).parent()).addClass("active");

            // This applies to PODIO INTEGRATION
            var apps = $("#appLabels").find("span");
            $(apps).removeClass("label-important");

            $("#overlay").fadeIn("fast");
            $("#" + currentVersionStatusElemId).hide();
            $.get("/podio/orgs/curspace/apps",function (apps) {

                appsLabelContent = "";
                for (var a = 0; a < apps.length; a++) {
                    appsLabelContent += "<span style=\"margin-right: 5px;\" class=\"label\" data-id=\"" + apps[a].id.toString() + "\">" + apps[a].key.trim() + "</span>";
                }
                $("#appLabels").html(appsLabelContent);
                apps = $("#appLabels").find("span");

                $.get("/manager/s/items/" + $(elem).attr("data-id"),function (response) {
                    if (response.data != null && response.data != undefined) {
                        if (response.data.length > 0) {
                            for (var i = 0; i < response.data.length; i++) {
                                for (var j = 0; j < apps.length; j++) {
                                    console.log("apps -> " + $(apps[j]).attr("data-id").toString() + " | " + response.data[i].destId);
                                    if ($(apps[j]).attr("data-id").toString() == response.data[i].destId) {
                                        console.log("HIT!");
                                        $(apps[j]).addClass("label-important");
                                    }
                                }
                            }
                        }
                    }

                    getPlaceholderContent(elem, query);
                }).error(function () {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Cannot contact server!");
                });

            }).error(function () {
                getPlaceholderContent(elem, query);
            });
            // end of PODIO integration

            break;
        case "script":
            $(".listItemMeta").removeClass("active");
            $(".listItemElement").removeClass("active");
            $(".listItemTemplate").removeClass("active");
            $(".listItemScript").removeClass("active");
            $("#script").removeClass("hidden");
            $($(elem).parent()).addClass("active");
            currentVersionStatusElemId = "versionNumberPage_ruby"

            $("#overlay").fadeIn("fast");
            $("#" + currentVersionStatusElemId).hide();
            $("#script").fadeIn(1, function () {
                $.get("/manager/s/g/" + query + "/ruby",function (response) {
                    tplRubyEditor.setValue(response.value);
                    tplRubyEditor.setSize("auto", $(window).height() - 128);

                    // Get history if any
                    $("#" + currentVersionStatusElemId).show();
                    getItemHistory(response.id,"scriptList", 0);
                    $("#" + currentVersionStatusElemId).attr("data-time", "current");
                    changeVersionToCurrent($("#" + currentVersionStatusElemId));
                    currentEditor = tplRubyEditor;

                    $("#scriptSaveBtn").attr("scriptdata-attr", response.id);
                    $("#overlay").fadeOut("fast");
                }).error(function () {
                        $("#overlay").fadeOut("fast");
                        Messenger().post("Cannot contact server!");
                    });
            });
            break;
        case "template":
            $(".listItemMeta").removeClass("active");
            $(".listItemElement").removeClass("active");
            $(".listItemTemplate").removeClass("active");
            $(".listItemScript").removeClass("active");
            $("#template").removeClass("hidden");
            currentVersionStatusElemId = "versionNumberPage_template"

            $("#overlay").fadeIn("fast");
            $("#" + currentVersionStatusElemId).hide();
            $("#template").fadeIn(1, function () {

                // Get contents through AJAX
                $.get("/manager/s/g/" + query + "/template",function (response) {
                    //$($("#template").find("textarea").first()).val(response.value);
                    tplHtmlEditor.setValue(response.value);
                    tplHtmlEditor.setSize("auto", $(window).height() - 208)
                    $("#templateSaveBtn").attr("tpldata-attr", response.id);

                    // Get history if any
                    $("#" + currentVersionStatusElemId).show();
                    getItemHistory(response.id,"templateList", 0);
                    $("#" + currentVersionStatusElemId).attr("data-time", "current");
                    changeVersionToCurrent($("#" + currentVersionStatusElemId));
                    currentEditor = tplHtmlEditor;

                }).error(function () {
                        // Messenger().post("Cannot contact server!");
                    });
            });
            $($(elem).parent()).addClass("active");

            // Get styles and scripts
            var styles = $("#styleLabels").find("span");
            var scripts = $("#scriptLabels").find("span");
            var metas = $("#metaLabels").find("span");
            $(styles).removeClass("label-important");
            $(scripts).removeClass("label-important");
            $(metas).removeClass("label-important");
            $.get("/manager/s/items/" + $(elem).attr("data-id"),function (response) {
                if (response.data != null && response.data != undefined) {
                    if (response.data.length > 0) {

                        for (var i = 0; i < response.data.length; i++) {
                            for (var j = 0; j < styles.length; j++) {
                                //console.log("styles -> " + $(styles[j]).attr("data-id").toString() + " | " + response.data[i].destId);
                                if ($(styles[j]).attr("data-id").toString() == response.data[i].destId) {
                                    $(styles[j]).addClass("label-important");
                                }
                            }
                        }

                        for (var i = 0; i < response.data.length; i++) {
                            for (var j = 0; j < scripts.length; j++) {
                                //console.log("scripts -> " + $(scripts[j]).attr("data-id").toString() + " | " + response.data[i].destId);
                                if ($(scripts[j]).attr("data-id").toString() == response.data[i].destId) {
                                    $(scripts[j]).addClass("label-important");
                                }
                            }
                        }

                        for (var i = 0; i < response.data.length; i++) {
                            for (var j = 0; j < metas.length; j++) {
                                //console.log("scripts -> " + $(scripts[j]).attr("data-id").toString() + " | " + response.data[i].destId);
                                if ($(metas[j]).attr("data-id").toString() == response.data[i].destId) {
                                    $(metas[j]).addClass("label-important");
                                }
                            }
                        }
                        $("#overlay").fadeOut("fast");
                    } else {
                        $("#overlay").fadeOut("fast");
                    }
                } else
                {
                    $("#overlay").fadeOut("fast");
                }
            }).error(function () {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Cannot contact server!");
                });

            break;
    }
}

// Update template
function saveTemplate(elem, data) {
    //value = $($($(elem).parents()[1]).find("textarea").first()).val();
    value = tplHtmlEditor.getValue();

    updateObj = {
        "value": value
    }

    $.ajax({
        url: "/manager/configurations/" + data,
        type: "PUT",
        data: {
            "data": updateObj,
            "time": $("#" + currentVersionStatusElemId).attr("data-time")
        },
        beforeSend: function () {
            $("#overlay").fadeIn("fast");
        },
        error: function () {
            $("#overlay").fadeOut("fast");
            $(elem).text("save");
            Messenger().post("Cannot contact server!");
        },
        success: function (response) {
            if (response.status == "success") {
                $("#overlay").fadeOut("fast");
                if (response.extra != null)
                {
                    if (response.extra.compliance_status == "saved_published")
                        Messenger().post("content has just been updated and published");
                    else if (response.extra.compliance_status == "saved")
                        Messenger().post("content has just been updated");
                } else
                    Messenger().post("Content has just been updated!");
                $(elem).text("save");
            }
            else {
                $("#overlay").fadeOut("fast");
                $(elem).text("save");
                if (response.message == "own-change")
                {
                    Messenger().post("content has just been updated but your change is pending for review and publishment");
                } else
                {
                    Messenger().post("Failure - reason: " + response.message);
                }
            }

            updatePageHistory("templateList", 0);
            changeVersionToCurrent($("#" + currentVersionStatusElemId));
        }
    });
}

// Update or save metatag
function saveMetatag(elem, data) {
    value = tplMetaEditor.getValue();

    updateObj = {
        "value": value
    }

    if (data != null && data != undefined) {
        $.ajax({
            url: "/manager/configurations/" + data,
            type: "PUT",
            data: {
                "data": updateObj,
                "time": $("#" + currentVersionStatusElemId).attr("data-time")
            },
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                $(elem).text("save");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    if (response.extra != null)
                    {
                        if (response.extra.compliance_status == "saved_published")
                            Messenger().post("content has just been updated and published");
                        else if (response.extra.compliance_status == "saved")
                            Messenger().post("content has just been updated");
                    } else
                        Messenger().post("Content has just been updated!");
                    $(elem).text("save");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    $(elem).text("save");
                    if (response.message == "own-change")
                    {
                        Messenger().post("content has just been updated but your change is pending for review and publishment");
                    } else
                    {
                        Messenger().post("Failure - reason: " + response.message);
                    }
                }

                updatePageHistory("metatagList", 0);
                changeVersionToCurrent($("#" + currentVersionStatusElemId));
            }
        });
    }
}

// Delete meta tag
function deleteMetatag() {
    var metatagId = $($($("#metatagList li.active").first()).find("a").first()).attr("data-id");

    if (metatagId != undefined) {
        $.ajax({
            url: "/manager/configurations/" + metatagId,
            type: "DELETE",
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Meta tag has just been deleted!");
                    $($("#metatagList li a[data-id=" + metatagId + "]").first()).remove();
                    $("#historyList li:not(:first)").remove();
                    $("#meta").fadeOut("fast");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Failure - reason: " + response.message);
                }
            }
        });
    }
}

// Update or save placeholder
function savePlaceholder(elem, data) {

    value = tplElementEditor.getValue();

    updateObj = {
        "value": value
    }

    if (data != null && data != undefined) {
        $.ajax({
            url: "/manager/configurations/" + data,
            type: "PUT",
            data: {
                "data": updateObj,
                "time": $("#" + currentVersionStatusElemId).attr("data-time")
            },
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                $("#elementSaveBtn").text("save");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    if (response.extra != null)
                    {
                        if (response.extra.compliance_status == "saved_published")
                            Messenger().post("content has just been updated and published");
                        else if (response.extra.compliance_status == "saved")
                            Messenger().post("content has just been updated");
                    } else
                        Messenger().post("Content has just been updated!");
                    $(elem).text("save");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    $("#elementSaveBtn").text("save");
                    if (response.message == "own-change")
                    {
                        Messenger().post("content has just been updated but your change is pending for review and publishment");
                    } else
                    {
                        Messenger().post("Failure - reason: " + response.message);
                    }
                }

                updatePageHistory("placeholderList", 0);
                changeVersionToCurrent($("#" + currentVersionStatusElemId));
            }
        });
    }
}

// Update or save script
function saveScript(elem, data) {

    value = tplRubyEditor.getValue();

    updateObj = {
        "value": value
    }

    if (data != null && data != undefined) {
        $.ajax({
            url: "/manager/configurations/" + data,
            type: "PUT",
            data: {
                "data": updateObj,
                "time": $("#" + currentVersionStatusElemId).attr("data-time")
            },
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                $(elem).text("save");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    if (response.extra != null)
                    {
                        if (response.extra.compliance_status == "saved_published")
                            Messenger().post("content has just been updated and published");
                        else if (response.extra.compliance_status == "saved")
                            Messenger().post("content has just been updated");
                    } else
                        Messenger().post("Content has just been updated!");
                    $(elem).text("save");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    $(elem).text("save");
                    if (response.message == "own-change")
                    {
                        Messenger().post("content has just been updated but your change is pending for review and publishment");
                    } else
                    {
                        Messenger().post("Failure - reason: " + response.message);
                    }
                }

                updatePageHistory("scriptList", 0);
                changeVersionToCurrent($("#" + currentVersionStatusElemId));
            }
        });
    }

}

/* Would create script here */
function createScript() {
    $.ajax({
        url: "/manager/configurations",
        type: "POST",
        data: {
            "key": $("#scriptCreate_name").val().trim(),
            "value": $("#scriptCreate_content").val().trim(),
            "cat": "ruby",
            "mime": "text/plain"
        },
        beforeSend: function () {
            $("#scriptCloseBtn").attr("disabled","disabled");
            $("#scriptCreateBtn").attr("disabled","disabled");
            $("#overlay").fadeIn("fast");
        },
        error: function () {
            $("#scriptCloseBtn").removeAttr("disabled");
            $("#scriptCreateBtn").removeAttr("disabled");
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
        success: function (response) {
            if (response.status == "success") {
                $("#overlay").fadeOut("fast");
                $("#scriptCloseBtn").removeAttr("disabled");
                $("#scriptCreateBtn").removeAttr("disabled");
                Messenger().post("Script has just been created!");
                var newListItem = $("<li class=\"listItemScript\"></li>");
                $(newListItem).append("<a href=\"javascript:void(0);\" onclick=\"showContent(this,'" + $("#scriptCreate_name").val().trim() + "','script')\"  data-id=\"" + response.data.newid.toString() + "\">" + $("#scriptCreate_name").val().trim() + "</a>");

                $("#scriptList").append($(newListItem));
            }
            else {
                $("#scriptCloseBtn").removeAttr("disabled");
                $("#scriptCreateBtn").removeAttr("disabled");
                $("#overlay").fadeOut("fast");
                Messenger().post("Failure - reason: " + response.message);
            }
        }
    });
}

function deleteScript() {
    var scriptId = $($($("#scriptList li.active").first()).find("a").first()).attr("data-id");

    if (scriptId != undefined) {
        $.ajax({
            url: "/manager/configurations/" + scriptId,
            type: "DELETE",
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Script has just been deleted!");
                    $($("#scriptList li a[data-id=" + scriptId + "]").first()).remove();
                    $("#historyList li:not(:first)").remove();
                    $("#script").fadeOut("fast");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Failure - reason: " + response.message);
                }
            }
        });
    }
}

/* Would create meta here */
function createMetatag() {
    $.ajax({
        url: "/manager/configurations",
        type: "POST",
        data: {
            "key": $("#metatagCreate_name").val().trim(),
            "value": $("#metatagCreate_content").val().trim(),
            "cat": "meta",
            "mime": "text/xml"
        },
        beforeSend: function () {
            $("#metatagCloseBtn").attr("disabled","disabled");
            $("#metatagCreateBtn").attr("disabled","disabled");
            $("#overlay").fadeIn("fast");
        },
        error: function () {
            $("#metatagCloseBtn").removeAttr("disabled");
            $("#metatagCreateBtn").removeAttr("disabled");
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
        success: function (response) {
            if (response.status == "success") {
                $("#overlay").fadeOut("fast");
                $("#metatagCloseBtn").removeAttr("disabled");
                $("#metatagCreateBtn").removeAttr("disabled");
                Messenger().post("Meta tag has just been created!");
                var newListItem = $("<li class=\"listItemMeta\"></li>");
                $(newListItem).append("<a href=\"javascript:void(0);\" onclick=\"showContent(this,'" + $("#metatagCreate_name").val().trim() + "','meta')\"  data-id=\"" + response.data.newid.toString() + "\">" + $("#metatagCreate_name").val().trim() + "</a>");

                $("#metatagList").append($(newListItem));
            }
            else {
                $("#metatagCloseBtn").removeAttr("disabled");
                $("#metatagCreateBtn").removeAttr("disabled");
                $("#overlay").fadeOut("fast");
                Messenger().post("Failure - reason: " + response.message);
            }
        }
    });
}

/* Would create placeholder here */
function createPlaceholder() {
    $.ajax({
        url: "/manager/configurations",
        type: "POST",
        data: {
            "key": $("#placeholderCreate_name").val().trim(),
            "value": $("#placeholderCreate_content").val().trim(),
            "cat": "placeholder",
            "mime": "text/html"
        },
        beforeSend: function () {
            $("#placeholderCloseBtn").attr("disabled","disabled");
            $("#placeholderCreateBtn").attr("disabled","disabled");
            $("#overlay").fadeIn("fast");
        },
        error: function () {
            $("#placeholderCloseBtn").removeAttr("disabled");
            $("#placeholderCreateBtn").removeAttr("disabled");
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
        success: function (response) {
            if (response.status == "success") {
                $("#overlay").fadeOut("fast");
                Messenger().post("Placeholder has just been created!");
                $("#placeholderCloseBtn").removeAttr("disabled");
                $("#placeholderCreateBtn").removeAttr("disabled");
                var newListItem = $("<li class=\"listItemElement\"></li>");
                $(newListItem).append("<a href=\"javascript:void(0);\" onclick=\"showContent(this,'" + $("#placeholderCreate_name").val().trim() + "','element')\"  data-id=\"" + response.data.newid.toString() + "\">" + $("#placeholderCreate_name").val().trim() + "</a>");

                $("#placeholderList").append($(newListItem));
            }
            else {
                $("#placeholderCloseBtn").removeAttr("disabled");
                $("#placeholderCreateBtn").removeAttr("disabled");
                $("#overlay").fadeOut("fast");
                Messenger().post("Failure - reason: " + response.message);
            }
        }
    });
}

function deletePlaceholder() {
    var placeholderId = $($($("#placeholderList li.active").first()).find("a").first()).attr("data-id");

    if (placeholderId != undefined) {
        $.ajax({
            url: "/manager/configurations/" + placeholderId,
            type: "DELETE",
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Placeholder has just been deleted!");
                    $($("#placeholderList li a[data-id=" + placeholderId + "]").first()).remove();
                    $("#historyList li:not(:first)").remove();
                    $("#element").fadeOut("fast");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Failure - reason: " + response.message);
                }
            }
        });
    }
}

/* Would create placeholder here */
function createTemplate() {
    $.ajax({
        url: "/manager/configurations",
        type: "POST",
        data: {
            "key": $("#templateCreate_name").val().trim(),
            "value": $("#templateCreate_content").val().trim(),
            "cat": "template",
            "mime": "text/html"
        },
        beforeSend: function () {
            $("#templateCloseBtn").attr("disabled","disabled");
            $("#templateCreateBtn").attr("disabled","disabled");
            $("#overlay").fadeIn("fast");
        },
        error: function () {
            $("#templateCloseBtn").removeAttr("disabled");
            $("#templateCreateBtn").removeAttr("disabled");
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
        success: function (response) {
            if (response.status == "success") {
                $("#overlay").fadeOut("fast");
                $("#templateCloseBtn").removeAttr("disabled");
                $("#templateCreateBtn").removeAttr("disabled");
                Messenger().post("Template has just been created!");
                var newListItem = $("<li class=\"listItemTemplate\"></li>");
                $(newListItem).append("<a href=\"javascript:void(0);\" onclick=\"showContent(this,'" + $("#templateCreate_name").val().trim() + "','template')\" data-id=\"" + response.data.newid + "\">" + $("#templateCreate_name").val().trim() + "</a>");
                $("#templateList").append($(newListItem));
            }
            else {
                $("#templateCloseBtn").removeAttr("disabled");
                $("#templateCreateBtn").removeAttr("disabled");
                $("#overlay").fadeOut("fast");
                Messenger().post("Failure - reason: " + response.message);
            }
        }
    });
}

function deleteTemplate() {
    var templateId = $($($("#templateList li.active").first()).find("a").first()).attr("data-id");

    if (templateId != undefined) {
        $.ajax({
            url: "/manager/configurations/" + templateId,
            type: "DELETE",
            beforeSend: function () {
                $("#overlay").fadeIn("fast");
            },
            error: function () {
                $("#overlay").fadeOut("fast");
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Template has just been deleted!");
                    $($("#templateList li a[data-id=" + templateId + "]").first()).remove();
                    $("#historyList li:not(:first)").remove();
                    $("#template").fadeOut("fast");
                }
                else {
                    $("#overlay").fadeOut("fast");
                    Messenger().post("Failure - reason: " + response.message);
                }
            }
        });
    }
}

function toggleMetatagVisibility() {
    $(".listItemMeta").fadeToggle("fast", function () {

    });

    if ($(".listItemMeta").css("opacity") == 1)
        $("#aMetaElementToggleVisibility").text("s");
    else
        $("#aMetaElementToggleVisibility").text("h");
}

function togglePlaceholderVisbility() {
    $(".listItemElement").fadeToggle("fast", function () {

    });

    if ($(".listItemElement").css("opacity") == 1)
        $("#aItemElementToggleVisibility").text("s");
    else
        $("#aItemElementToggleVisibility").text("h");
}

function toggleScriptVisibility() {
    $(".listItemScript").fadeToggle("fast", function () {

    });

    if ($(".listItemScript").css("opacity") == 1)
        $("#aScriptToggleVisibility").text("s");
    else
        $("#aScriptToggleVisibility").text("h");
}

function toggleTemplateVisibility() {
    $(".listItemTemplate").fadeToggle("fast", function () {

    });

    if ($(".listItemTemplate").css("opacity") == 1)
        $("#aTemplateToggleVisibility").text("s");
    else
        $("#aTemplateToggleVisibility").text("h");
}

$(function () {

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $(window).resize(function () {
        window_height = $(this).height();
        if (tplMetaEditor != null && tplMetaEditor != undefined)
            tplMetaEditor.setSize("auto", $(window).height() - 128);
        if (tplHtmlEditor != null && tplHtmlEditor != undefined)
            tplHtmlEditor.setSize("auto", window_height - 208);
        if (tplElementEditor != null && tplElementEditor != undefined)
            tplElementEditor.setSize("auto", window_height - 168);
        if (tplRubyEditor != null && tplRubyEditor != undefined)
            tplRubyEditor.setSize("auto", window_height - 128);

    });

    $("#templateSaveBtn").on("click", function () {
        $(this).text("saving...");
        data = $(this).attr("tpldata-attr");

        if (data != null && data != undefined && data != "")
            saveTemplate($(this), data);
        else {
            //alert("Erm! Dat template doesn't exist!");
            Messenger().post("Erm! Dat template doesn't exist!");
            $(this).text("save");
        }
    });

    $("#metaSaveBtn").on("click", function () {
        $(this).text("saving...");
        data = $(this).attr("metatagdata-attr");

        if (data != null && data != undefined && data != "")
            saveMetatag($(this), data);
        else {
            Messenger().post("Erm! Dat element doesn't exist!");
            saveMetatag($(this), data);
        }
    });

    $("#elementSaveBtn").on("click", function () {
        $(this).text("saving...");
        data = $(this).attr("tpldata-attr");

        if (data != null && data != undefined && data != "")
            savePlaceholder($(this), data);
        else {
            Messenger().post("Erm! Dat element doesn't exist!");
            savePlaceholder($(this), data);
        }
    });

    $("#scriptSaveBtn").on("click", function () {
        $(this).text("saving...");
        data = $(this).attr("scriptdata-attr");

        if (data != null && data != undefined && data != "")
            saveScript($(this), data);
        else {
            Messenger().post("Erm! Dat element doesn't exist!");
            saveScript($(this), data);
        }
    });

    $("#styleLabels").on("click", "span", function (e) {
        var srcId = $($("#templateList").find("li.active").find("a").first()).attr("data-id");
        var destId = $(this).attr("data-id");
        var $this = $(this);

        if (!$(this).hasClass("label-important")) {
            $.get("/manager/s/item/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Style has just been activated!");
                $this.addClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
        else {
            $.get("/manager/s/ritem/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Style has just been deactivated!");
                $this.removeClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
    });

    $("#scriptLabels").on("click", "span", function (e) {
        var srcId = $($("#templateList").find("li.active").find("a").first()).attr("data-id");
        var destId = $(this).attr("data-id");
        var $this = $(this);

        if (!$(this).hasClass("label-important")) {
            $.get("/manager/s/item/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Script has just been activated!");
                $this.addClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
        else {
            $.get("/manager/s/ritem/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Script has just been deactivated!");
                $this.removeClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
    });

    $("#metaLabels").on("click", "span", function (e) {
        var srcId = $($("#templateList").find("li.active").find("a").first()).attr("data-id");
        var destId = $(this).attr("data-id");
        var $this = $(this);

        if (!$(this).hasClass("label-important")) {
            $.get("/manager/s/item/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Meta has just been activated!");
                $this.addClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
        else {
            $.get("/manager/s/ritem/" + destId + "/" + srcId,function (response) {
                //alert(response.message);
                Messenger().post("Meta has just been deactivated!");
                $this.removeClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
    });

    $("#appLabels").on("click", "span", function (e) {
        var srcId = $($("#placeholderList").find("li.active").find("a").first()).attr("data-id");
        var destId = $(this).attr("data-id");
        var $this = $(this);
        var apps = $("#appLabels").find("span");

        for (var i = 0; i < apps.length; i++) {
            if ($(apps[i]).is($this) == false) {
                if ($(apps[i]).hasClass("label-important")) {
                    var $other = $(apps[i])
                    var otherDestId = $(apps[i]).attr("data-id");
                    $.get("/manager/s/ritem/" + otherDestId + "/" + srcId, function (response) {
                        $other.removeClass("label-important");
                    });
                }
            }
        }

        if (!$(this).hasClass("label-important")) {
            $.get("/manager/s/item/" + destId + "/" + srcId, { "type": "app_assoc" },function (response) {
                //alert(response.message);
                Messenger().post("App has just been activated!");
                $this.addClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
        else {
            $.get("/manager/s/ritem/" + destId + "/" + srcId,function (response) {
                Messenger().post("App has just been deactivated!");
                $this.removeClass("label-important");
            }).error(function () {
                    Messenger().post("Cannot contact server!");
                });
        }
    });

    // Some keyup events for modals
    $("#metatagCreate_name").on("keyup", function (e) {
        var value = $(this).val();

        if (value.length < 6 || !const_key_regex.test(value)) {
            if (value.length > 0)
                $(this).css("background-color", "#f2dede");
            else
                $(this).css("background-color", "transparent");
            $("#metatagCreateBtnCreate").attr("disabled", "disabled");
        }
        else {
            $(this).css("background-color", "transparent");
            $("#metatagCreateBtnCreate").removeAttr("disabled");
        }
    });

    // Some keyup events for modals
    $("#placeholderCreate_name").on("keyup", function (e) {
        var value = $(this).val();

        if (value.length < 6 || !const_key_regex.test(value)) {
            if (value.length > 0)
                $(this).css("background-color", "#f2dede");
            else
                $(this).css("background-color", "transparent");
            $("#placeholderCreateBtnCreate").attr("disabled", "disabled");
        }
        else {
            $(this).css("background-color", "transparent");
            $("#placeholderCreateBtnCreate").removeAttr("disabled");
        }
    });

    // Some keyup events for modals
    $("#scriptCreate_name").on("keyup", function (e) {
        var value = $(this).val();

        if (value.length < 6 || !const_key_regex.test(value)) {
            if (value.length > 0)
                $(this).css("background-color", "#f2dede");
            else
                $(this).css("background-color", "transparent");
            $("#scriptCreateBtnCreate").attr("disabled", "disabled");
        }
        else {
            $(this).css("background-color", "transparent");
            $("#scriptCreateBtnCreate").removeAttr("disabled");
        }
    });

    $("#templateCreate_name").on("keyup", function (e) {
        var value = $(this).val();

        if (value.length < 6 || !const_key_regex.test(value)) {
            if (value.length > 0)
                $(this).css("background-color", "#f2dede");
            else
                $(this).css("background-color", "transparent");
            $("#templateCreateBtnCreate").attr("disabled", "disabled");
        }
        else {
            $(this).css("background-color", "transparent");
            $("#templateCreateBtnCreate").removeAttr("disabled");
        }
    });

    $("#metatagDelete").on("shown", function () {
        var selectedItems = $("#metatagList li.active").length;

        if (selectedItems > 0) {
            $("#metatagDeleteMsg").css("display", "block");
            $("#metatagDeleteInvalidMsg").css("display", "none");
            $("#metatagDeleteButton").removeAttr("disabled");
        }
        else {
            $("#metatagDeleteMsg").css("display", "none");
            $("#metatagDeleteInvalidMsg").css("display", "block");
            $("#metatagDeleteButton").attr("disabled", "disabled");
        }
    });

    $("#placeholderDelete").on("shown", function () {
        var selectedItems = $("#placeholderList li.active").length;

        if (selectedItems > 0) {
            $("#placeholderDeleteMsg").css("display", "block");
            $("#placeholderDeleteInvalidMsg").css("display", "none");
            $("#placeholderDeleteButton").removeAttr("disabled");
        }
        else {
            $("#placeholderDeleteMsg").css("display", "none");
            $("#placeholderDeleteInvalidMsg").css("display", "block");
            $("#placeholderDeleteButton").attr("disabled", "disabled");
        }
    });

    $("#placeholderDelete").on("hidden", function () {
        $("#placeholderDeleteMsg").css("display", "none");
        $("#placeholderDeleteInvalidMsg").css("display", "none");
        $("#placeholderDeleteButton").attr("disabled", "disabled");
    });

    $("#scriptDelete").on("shown", function () {
        var selectedItems = $("#scriptList li.active").length;

        if (selectedItems > 0) {
            $("#scriptDeleteMsg").css("display", "block");
            $("#scriptDeleteInvalidMsg").css("display", "none");
            $("#scriptDeleteButton").removeAttr("disabled");
        }
        else {
            $("#scriptDeleteMsg").css("display", "none");
            $("#scriptDeleteInvalidMsg").css("display", "block");
            $("#scriptDeleteButton").attr("disabled", "disabled");
        }
    });

    $("#scriptDelete").on("hidden", function () {
        $("#scriptDeleteButton").attr("disabled", "disabled");
        $("#scriptDeleteMsg").css("display", "none");
        $("#scriptDeleteInvalidMsg").css("display", "none");
    });

    $("#templateDelete").on("shown", function () {
        var selectedItems = $("#templateList li.active").length;

        if (selectedItems > 0) {
            $("#templateDeleteMsg").css("display", "block");
            $("#templateDeleteInvalidMsg").css("display", "none");
            $("#templateDeleteButton").removeAttr("disabled");
        }
        else {
            $("#templateDeleteMsg").css("display", "none");
            $("#templateDeleteInvalidMsg").css("display", "block");
            $("#templateDeleteButton").attr("disabled", "disabled");
        }
    });

    $("#templateDelete").on("hidden", function () {
        $("#templateDeleteButton").attr("disabled", "disabled");
        $("#templateDeleteMsg").css("display", "none");
        $("#templateDeleteInvalidMsg").css("display", "none");
    });

    /* Code Compare */

    $("#codeCompareModal").on("shown", function(){
        var id = $(this).attr("data-id"),
            datetime = $(this).attr("data-time"),
            $this = $(this);

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

                var editorValue = currentEditor.getValue();
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
        var datetimeObj = $(this).attr("data-time");

        var cEditor = currentEditor;

        changeVersionToVersion($("#" + currentVersionStatusElemId), datetimeObj);
        cEditor.setValue(revertedValue);
    });

    $(".switchToCurrentPage").on("click", function(e){
        e.stopPropagation();

        getInfoForPageEdit();
        changeVersionToCurrent($("#" + currentVersionStatusElemId));
    });

    $(".historyNext #historyListNext").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        var category = $($($($("#elementsList li.active").first()).parents("ul:first")).find("li:first")).text().replace(/\+\-h/g,'').trim().toLowerCase();

        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) + 5));
        console.log(category);
        console.log(page);
        if (category == "placeholders")
            updatePageHistory("placeholderList", parseInt(page) + 5);
        else if (category == "metatags")
            updatePageHistory("metatagList", parseInt(page) + 5);
        else if (category == "scripts")
            updatePageHistory("scriptList", parseInt(page) + 5);
        else if (category == "templateList")
            updatePageHistory("templateList", parseInt(page) + 5);
    });

    $(".historyPrev #historyListPrev").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        var category = $($($($("#elementsList li.active").first()).parents("ul:first")).find("li:first")).text().replace(/\+\-h/g,'').trim().toLowerCase();

        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) - 5));
        console.log(category);
        console.log(page);
        if (category == "placeholders")
            updatePageHistory("placeholderList", parseInt(page) - 5);
        else if (category == "metatags")
            updatePageHistory("metatagList", parseInt(page) - 5);
        else if (category == "scripts")
            updatePageHistory("scriptList", parseInt(page) - 5);
        else if (category == "templateList")
            updatePageHistory("templateList", parseInt(page) - 5);
    });

    /* */

    $(".cCodeCleanupBtn").on("click", function(e){
        autoFormatSelection(currentEditor);
    });

});