var const_key_regex = /^[a-zA-Z0-9\-]+$/i;
var editor;

var tplVersionedCurrent = "<i class=\"icon-check\"></i>&nbsp;current";
var tplVersioned = "<i class=\"icon-exclamation-sign\"></i>&nbsp;" // version is put after this

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

// Code Cleanup
function getSelectedRange(lEditor) {
    return { from: lEditor.getCursor(true), to: lEditor.getCursor(false) };
}

function autoFormatSelection(lEditor) {
    var range = getSelectedRange(lEditor);
    lEditor.autoFormatRange(range.from, range.to);
}
//

function changeVersionToCurrent(){
    $("#versionNumberPage").html(tplVersionedCurrent);
    $("#versionNumberPage").attr("data-time","current");
    $("#switchToCurrentPage").hide();
}

function changeVersionToVersion(elem, datetimeObj){
    $("#versionNumberPage").html(tplVersioned + datetimeObj.toLocaleString());
    $("#versionNumberPage").attr("data-time", $(elem).attr("data-time"));
    $("#switchToCurrentPage").show();
}

// GET HISTORY
// Generic get item history method
function getItemHistory(id, offset)
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
                console.log("HIT HERE 1");
            }
            else if ( response.nav.max == 1 )
            {
                $($($(elem).parent()).find(".historyNext").first()).hide();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
                console.log("HIT HERE 4");
            }
            else if ( response.nav.max > 1 && response.nav.current == 1  && response.nav.current < response.nav.max)
            {
                console.log("HIT HERE 2");
                $($($(elem).parent()).find(".historyNext").first()).show();
                $($($(elem).parent()).find(".historyPrev").first()).hide();
            }
            else if ( response.nav.max > 1 && response.nav.current > 1  && response.nav.current < response.nav.max)
            {
                console.log("HIT HERE 2");
                $($($(elem).parent()).find(".historyNext").first()).show();
                $($($(elem).parent()).find(".historyPrev").first()).show();
            } else if ( response.nav.max > 1 && response.nav.current == response.nav.max)
            {
                console.log("HIT HERE 3");
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
                        $("#codeCompareModal").attr("data-id", $($($("#pageList li.active").first()).find("a").first()).attr("data-id"));

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
    var elems = $("#pageList li.active");

    if (elems.length == 1)
    {
        console.log("running... at " + offset);
        var id = $($(elems.first()).find("a:first")).attr("data-id");

        getItemHistory(id, offset);
    } else
    {
        $($("#historyList").find("li:not(:first)")).remove();
        $($($("#pageList").parent().find("#historyList:first")).next("div")).hide();
    }
}
//

function getInfoForPageEdit()
{
    $("#overlay").fadeIn("fast");
	$.get("/manager/s/i/"+$($($("#pageList li.active").first()).find("a").first()).attr("data-id"),
	function(response) {
		if (response != null && response != undefined)
		{
			//$("#editModalContentTextarea").val(response.value.trim());
			var pageTitle = $($($("#pageList li.active").first()).find("a").first()).text();
			$("#editModalName").val(pageTitle);
			$("#curPageTitle").text(pageTitle);
			/*$("#editModalTemplate option").filter(function(){
				console.log($(this).text());
				return $(this).text() == response.cat.trim()
			}).prop("selected",true);*/
			//$("#editModalContent").show();
			editor.setValue(response.value.trim());
            $("#overlay").fadeOut("fast");
		}
	}).error(function(){
        $("#overlay").fadeOut("fast");
        Messenger().post("Cannot contact server!");
    });
}

function createPage()
{
	$.ajax({
		url: "/manager/configurations",
		type: "POST",
		data: {
			"type" : "page",
			"key": $("#createModalName").val().toLowerCase().trim(),
			"value": editor.getValue().trim(),
			"cat" : "page",
			"mime" : "text/html",
			"tpl" : $("#createModalTemplateSelect").val() 
		},
		beforeSend: function(){
			$("#overlay").fadeIn("fast");	
		},
        error: function(){
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
		success: function(response){
			if (response.status == "success")
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("Page has just been created!");
				//$("#iframePreview").fadeIn("fast");
				newListItem = $("<li class=\"listItem\"><a href=\"javascript:void(0);\" data-id=\"" + response.data.newid + "\" data-destid=\"" + $("#createModalTemplateSelect").val() + "\">" + $("#createModalName").val().toLowerCase().trim() + "</a></li>")
				$("#pageList").append($(newListItem));	
				
				// Switch mode to edit
				$("#pageSaveBtn").text("save");
				$("#pageSaveBtn").attr("content-mode","edit");
				
				// Select the item in the list immediately
				$("#pageList li.listItem").filter(function(){
					//console.log($(this).text() + " | " + $("#createModalName").val().toLowerCase().trim());
					return $(this).text() == $("#createModalName").val().toLowerCase().trim()
				}).addClass("active");
				
				// Clear create modal input
				$("#createModalName").val("");
				
				editor.setOption("readOnly", false);

                updatePageHistory(0);
			}
			else
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("Failure - reason: " + response.message);
			}
		}
	});
}

function editPage()
{
	var pageId = $($($("#pageList li.active").first()).find("a").first()).attr("data-id");
	var tplId = $($($("#pageList li.active").first()).find("a").first()).attr("data-destId");
	
	updateObj = {
		"key" : $("#curPageTitle").text(),
		"value" : editor.getValue().trim(),
		"cat" : "page"
	}

	$.ajax({
		url: "/manager/configurations/" + pageId,
		type: "PUT",
		data: {
			"flag" : "page",
			"data" : updateObj,
			"tpl" : tplId,
            "time" : $("#versionNumberPage").attr("data-time")
		},
		beforeSend: function(){
			$("#overlay").fadeIn("fast");	
		},
        error: function(){
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
		success: function(response){
			if (response.status == "success")
			{
				$("#overlay").fadeOut("fast");
                if (response.extra != null)
                {
                    if (response.extra.compliance_status == "saved_published")
                        Messenger().post("content has just been updated and published");
                    else if (response.extra.compliance_status == "saved")
                        Messenger().post("content has just been updated");
                } else
                    Messenger().post("Content has just been updated!");

				 $($($("#pageList li.active").first()).find("a").first()).attr("data-id", response.data.id);
				 $($($("#pageList li.active").first()).find("a").first()).text($("#curPageTitle").text());

                changeVersionToCurrent();
                updatePageHistory(0);
			}
			else
			{
				$("#overlay").fadeOut("fast");
                if (response.message == "own-change")
                {
                    Messenger().post("content has just been updated but your change is pending for review and publishment");
                    changeVersionToCurrent();
                    updatePageHistory(0);
                } else
                {
                    Messenger().post("Failure - reason: " + response.message);
                }
			}
		}
	});
}

function deletePage()
{
	var pageId = $($($("#pageList li.active").first()).find("a").first()).attr("data-id");
	$.ajax({
		url: "/manager/configurations/" + pageId,
		type: "DELETE",
		beforeSend: function(){
			$("#overlay").fadeIn("fast");	
		},
        error: function(){
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        },
		success: function(response){
			if (response.status == "success")
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("Page content has just been deleted!");
				$($("#pageList li.active").first()).remove();
				
				// Reset everything
				$("#pageSaveBtn").removeAttr("content-mode");
				$("#pageSaveBtn").attr("disabled","disabled");
                $("#pageContentCleanupBtn").attr("disabled","disabled");
				$("#curPageTitleDiv").hide();
			
				editor.setValue("");
				$("#pageList li").removeClass("active");

                $("#historyList").find("li:not(:first)").remove();
			}
			else
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("Failure - reason: " + response.message);
			}
		}
	});
}

$(function(){
	
	Messenger.options = {
		extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
		theme: 'air'
	};
	
	var mixedMode = {
        name: "htmlmixed",
        scriptTypes: [{matches: /\/x-handlebars-template|\/x-mustache/i,
                       mode: null}]
    };
    CodeMirror.commands.autocomplete = function(cm) {
        CodeMirror.showHint(cm, CodeMirror.hint.html);
    }
    editor = CodeMirror.fromTextArea(document.getElementById("page_quickEditor"), {
    	mode: mixedMode, 
    	tabMode: "indent",
        extraKeys: {"Ctrl-Space": "autocomplete",
                    "Ctrl-S": function(){
                        var os = navigator.platform.toLowerCase();

                        if (os.indexOf("mac") < 0) {
                            var mode = $("#pageSaveBtn").attr("content-mode");

                            if (mode != null && mode != undefined)
                            {
                                if (mode == "create")
                                    createPage();
                                else if (mode == "edit")
                                    editPage();
                            }
                        }
                    },
                    "Cmd-S": function(){
                        var os = navigator.platform.toLowerCase();

                        if (os.indexOf("mac") >= 0) {
                            var mode = $("#pageSaveBtn").attr("content-mode");

                            if (mode != null && mode != undefined)
                            {
                                if (mode == "create")
                                    createPage();
                                else if (mode == "edit")
                                    editPage();
                            }
                        }
                    }
        },
    	lineNumbers: true
    });
    editor.setSize("auto", 768);
    editor.setOption("readOnly", true);

    // ITEM HISTORY
    /*$.timer(function(){
        console.log("From timer: " + currentHistoryPage);
        updatePageHistory(currentHistoryPage);
    }, 10000, true);*/
    $(".historyNext #historyListNext").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) + 5));
        console.log(page);
        updatePageHistory(parseInt(page) + 5);
    });
    $(".historyPrev #historyListPrev").on("click", function(e){
        e.stopPropagation();

        var page = $($(this).parent().parent().parent()).attr("data-page");
        $($(this).parent().parent().parent()).attr("data-page", (parseInt(page) - 5));
        console.log(page);
        updatePageHistory(parseInt(page) - 5);
    });
    //

	$("#pageList").on("click", "li.listItem", function(e){
		e.stopPropagation();
		
		$("li.listItem").removeClass("active");
		
		$(this).addClass("active");
		
		$("#pageSaveBtn").attr("content-mode","edit");
		$("#pageSaveBtn").removeAttr("disabled");
        $("#pageContentCleanupBtn").removeAttr("disabled");
		editor.setOption("readOnly", false);
		$("#curPageTitleDiv").show();
		
		getInfoForPageEdit();
        getItemHistory($($(this).find("a:first")).attr("data-id"), 0);
        changeVersionToCurrent();

        // Reset data page
        $(".historyWidget").attr("data-page","0");
	});
	
	$("#createModalName").on("keyup", function(e){
		var value = $(this).val();
		
		if (value.length < 3 || !const_key_regex.test(value))
		{
			if (value.length > 0)
				$(this).css("background-color","#f2dede");
			else
				$(this).css("background-color","transparent");
			$("#createModalBtnCreate").attr("disabled","disabled");
			$("#pageSaveBtn").attr("disabled","disabled");
            $("#pageContentCleanupBtn").attr("disabled","disabled");
			editor.setOption("readOnly", true);
		}
		else
		{
			$(this).css("background-color","transparent");
			$("#createModalBtnCreate").removeAttr("disabled");
			$("#pageSaveBtn").removeAttr("disabled");
            $("#pageContentCleanupBtn").removeAttr("disabled");
			editor.setOption("readOnly", false);
		}
	});
	
	$('#createModal').on('shown', function () {
		$("#pageSaveBtn").attr("content-mode","create");
		$("#pageSaveBtn").attr("disabled","disabled");
        $("#pageContentCleanupBtn").attr("disabled","disabled");
		$("#curPageTitleDiv").hide();
	
		$("#createModalName").val("");
		$("#createModalName").css("background","transparent");
        $("#createModalTemplateSelect").val("");
		editor.setValue("");
		editor.setOption("readOnly", true);
		$("#pageList li").removeClass("active");
	})
	
	$('#createModal').on('hidden', function () {
		if ($("#pageSaveBtn").attr("disabled") != "disabled"){
			$("#curPageTitleDiv").show();
			$("#curPageTitle").text($("#createModalName").val());

            changeVersionToCurrent();
		}
	})
	
	
	$('#editModal').on('shown', function () {
		var pageId = $($($("#pageList li.active").first()).find("a").first()).attr("data-id");
		var tplId = $($($("#pageList li.active").first()).find("a").first()).attr("data-destId");
		
		$("#pageSaveBtn").attr("content-mode","edit");
		
		if (pageId == undefined)
		{
			//$("#editModalContent").hide();
			$("#editModalMsg").fadeIn("fast");
		}else
		{
			//$("#editModalMsg").hide();
			$("#editModalContent").fadeIn("fast");
			$("#editModalBtnSave").show();
			
			// show active template for page
			$("#editModalTemplateSelect").val(tplId);
		}
  	});
  	
  	$('#editModal').on('hidden', function () {
		$("#editModalContent").hide();
		$("#editModalMsg").hide();
		$("#editModalBtnSave").hide();
  	});

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
                $.data(document.getElementById("codeCompareModalRevertBtn"), "value", response.data.value);

                var editorValue = editor.getValue();
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
    });

    $("#codeCompareModalRevertBtn").on("click", function(){
        var revertedValue = $.data(document.getElementById("codeCompareModalRevertBtn"), "value");
        $("#codeCompareModal").modal("hide");

        // Parse version number
        var datetimeObj = new Date(Date.parse($(this).attr("data-time")));
        changeVersionToVersion($(this), datetimeObj);
        editor.setValue(revertedValue);
    });

    $("#switchToCurrentPage").on("click", function(){
        getInfoForPageEdit();
        changeVersionToCurrent();
    });
	
	$("#editModalName").on("keyup", function(e){
		var value = $(this).val();
		
		if (value.length < 3 || !const_key_regex.test(value))
		{
			if (value.length > 0)
				$(this).css("background-color","#f2dede");
			else
				$(this).css("background-color","transparent");
			$("#editModalBtnSave").attr("disabled","disabled");
			$("#pageSaveBtn").attr("disabled","disabled");
            $("#pageContentCleanupBtn").attr("disabled","disabled");
			editor.setOption("readOnly", true);
		}
		else
		{
			$("#curPageTitle").text($(this).val());
			$(this).css("background-color","transparent");
			$("#editModalBtnSave").removeAttr("disabled");
			$("#pageSaveBtn").removeAttr("disabled");
            $("#pageContentCleanupBtn").removeAttr("disabled");
			editor.setOption("readOnly", false);
		}
	});
	
	$("#pageSaveBtn").on("click", function(e){
		var mode = $("#pageSaveBtn").attr("content-mode");
		
		if (mode != null && mode != undefined)
		{
			if (mode == "create")
				createPage();
			else if (mode == "edit")
				editPage();
		}
	});

    $("#pageContentCleanupBtn").on("click", function(e){
        autoFormatSelection(editor);
    });
	
	$("#editModalTemplateSelect").on("change",function(){
		var listItemElem = $($($("#pageList li.active").first()).find("a").first());
		var tplValue = $(this).val(); 
		
		$(listItemElem).attr("data-destId", tplValue);
	});
	
});