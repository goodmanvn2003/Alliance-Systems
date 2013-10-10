var const_name_regex = /^[a-zA-Z0-9]+$/i
var window_height = $(window).height() - 128;
var editor;
var editorMode = {
	mode: "", 
	tabMode: "indent",
	lineNumbers: true,
    extraKeys: {
        "Ctrl-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") < 0) {
                var file = $("#fileSaveBtn").attr("data-path");

                $("#overlay").fadeIn("fast");
                $.post("/upload/save", {
                    "file": file,
                    "fileContent": editor.getValue().trim()
                }, function(response){
                    if (response == "success")
                    {
                        $("#overlay").fadeOut("fast");
                        Messenger().post("file \"" + file + "\" has just been saved!");
                    }
                    else
                    {
                        $("#overlay").fadeOut("fast");
                        Messenger().post("we were unable to save file \"" + file + "\" at the moment!");
                    }
                }).error(function(){
                        $("#overlay").fadeOut("fast");
                        Messenger().post("Cannot contact server!");
                    });
            }
        },
        "Cmd-S": function () {
            var os = navigator.platform.toLowerCase();

            if (os.indexOf("mac") >= 0) {
                var file = $("#fileSaveBtn").attr("data-path");

                $("#overlay").fadeIn("fast");
                $.post("/upload/save", {
                    "file": file,
                    "fileContent": editor.getValue().trim()
                }, function(response){
                    if (response == "success")
                    {
                        $("#overlay").fadeOut("fast");
                        Messenger().post("file \"" + file + "\" has just been saved!");
                    }
                    else
                    {
                        $("#overlay").fadeOut("fast");
                        Messenger().post("we were unable to save file \"" + file + "\" at the moment!");
                    }
                }).error(function(){
                        $("#overlay").fadeOut("fast");
                        Messenger().post("Cannot contact server!");
                    });
            }
        }
    }
};

editor =  CodeMirror.fromTextArea(document.getElementById("fileText"), editorMode);
editor.setSize("auto", window_height);

// Code Cleanup
function getSelectedRange(lEditor) {
    return { from: lEditor.getCursor(true), to: lEditor.getCursor(false) };
}

function autoFormatSelection(lEditor) {
    var range = getSelectedRange(lEditor);
    lEditor.autoFormatRange(range.from, range.to);
}
//

function showContent(elem,query,type,cat)
{
	$(".fileItem").hide();
	switch (type)
	{
		case "editor":
			// $("#fileEdit").removeClass("hidden");
			if (cat == "js")
				editor.setOption("mode","text/javascript");
			else if (cat == "css")
				editor.setOption("mode","text/css");

			$("#overlay").fadeIn("fast");
			$.get("/manager/s/g/"+query+"/"+cat, function(response){
				if (response.value != undefined && response.id != undefined)
				{
					$.get("/upload/file",{
						"file": response.value.trim()	
					}, function(data){
						$("#textFileTitle").text(response.value);
                        $("#fileSaveBtn").removeAttr("disabled");
                        $("#fileEdit").fadeIn("fast");
                        editor.setValue(data);
						$("#overlay").fadeOut("fast");
					}).error(function(){
                        $("#overlay").fadeOut("fast");
                        $("#fileSaveBtn").attr("disabled","disabled");
                        $("#fileEdit").fadeOut("fast");
                        editor.setValue('');
                        Messenger().post("Unable to load file");
                    });
				} else
				{
					$("#overlay").fadeOut("fast");
				}
			}).error(function(){
                $("#overlay").fadeOut("fast");
                Messenger().post("Cannot contact server!");
            });
			
			break;
		case "viewer":
			// $("#imageViewer").removeClass("hidden");
			$("#imageViewer").fadeIn("fast");
			$("#imagePreview").attr("src",query);
			$("#imgFileTitle").text(query);
			break;
		default:
	}
}

// TEST
function recursively_parsejson(jsonObj)
{
	var elem = "<ul>";
	$.each(jsonObj, function(i,v)
	{	
		var item = "";

		if (v.items != undefined)
			item = "<li><input type=\"checkbox\" id=\"item-" + v.path.replace(/[^a-zA-Z0-9]/g,"") + "\" /><label for=\"item-" + v.path.replace(/[^a-zA-Z0-9]/g,"") + "\">" + v.name + "</label>";
		else
		{
			if (v.path == "")
				item = "<li><a href=\"#\" parent-id=\"" + v.parent + "\" class=\"textFile upload\">[" + v.name + "]</a>";
			else	
				item = "<li class=\"dataItem\"><a class=\"dataDelete\" href=\"#\" style=\"color:#B32222;display:none;font-size:9px;margin:0px 5px 0 5px;\">x</a><a href=\"#\" parent-id=\"" + v.parent + "\" data-id=\"" + (v.fileid == undefined ? "" : v.fileid) + "\" data-path=\"" + v.path + "\" class=\"file\">" + v.name + "</a>";
		}
		
		if (v.items != undefined) 
			if (v.items.length > 0)
				item += recursively_parsejson(v.items);
				
		item += "</li>";
		elem += item;
	});	

	elem += "</ul>";
	return elem;
}

function get_files(data)
{
	var parent = "<ul class=\"folder\">";
	$.each(data.items, function(i,v)
	{
		var item = "";

		if (v.items != undefined)
			item = "<li><input type=\"checkbox\" id=\"item-" + v.path.replace(/[^a-zA-Z0-9]/g,"") + "\" /><label for=\"item-" + v.path.replace(/[^a-zA-Z0-9]/g,"") + "\">" + v.name + "</label>";
		else
		{
			if (v.path == "")
				item = "<li><a href=\"#\" parent-id=\"" + v.parent + "\" class=\"textFile upload\">[" + v.name + "]</a>";
			else	
				item = "<li class=\"dataItem\"><a class=\"dataDelete\" href=\"#\" style=\"color:#B32222;display:none;font-size:9px;margin:0px 5px 0 5px;\">x</a><a href=\"#\" parent-id=\"" + v.parent + "\" data-id=\"" + (v.fileid == undefined ? "" : v.fileid) + "\" data-path=\"" + v.path + "\" class=\"file\">" + v.name + "</a>";
		}
					
		if (v.items.length > 0)
			item +=	recursively_parsejson(v.items);

		item += "</li>";
		parent += item;
	});
	parent += "</ul>";
	
	$(".css-treeview:first").html(parent);
}

function get_file_extension(file)
{
	var extension = file.substr((file.lastIndexOf('.') + 1));
	return extension;
}
//

$(function(){

	Messenger.options = {
		extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
		theme: 'air'
	};
	
	$(window).resize(function(){
		window_height = $(this).height() - 128;
		editor.setSize("auto", window_height);
	});
	
	// TEST
	$.getJSON("/manager/files", function(data){
		get_files(data);
	}).error(function(){
        Messenger().post("Unable to get files from server");
    });
	//
	
	$("#uploadIframe").load(function(){
		var response = JSON.parse($(this).contents().find("body").text());
		
		if (response.status == "success")
		{
			$.getJSON("/manager/files", function(data)
			{
				get_files(data);
			}).error(function(){
                Messenger().post("Unable to get files from server");
            });
		} else
		{
			//alert(response.message);
            Messenger().post("Unable to get files from server");
		}
	});
	
	$(".css-treeview").on("mouseover", "li.dataItem" ,function(e){
		$($(this).find("a").first()).stop().fadeIn(1);
	}).on("mouseout", "li.dataItem", function(e){
		$($(this).find("a").first()).stop().fadeOut(1);
	});
	
	$(".css-treeview").on("click","li.dataItem a.dataDelete", function(e){
		e.stopPropagation();
		var file = $($(this).next()).attr("data-path");
		var fileId = $($(this).next()).attr("data-id");
		var fileCat = $($(this).next()).attr("parent-id");
		var fileExt = get_file_extension($($(this).next()).attr("data-path"));
		
		if(confirm("Are you sure?"))
		{
			$("#overlay").fadeIn("fast");
			$.ajax({
				url: "/upload/del", 
				type: "delete",
				data: {
					"file": file,
					"fileId": fileId,
					"fileCat": fileExt
				},
                error: function(){
                    Messenger().post("Cannot contact server!");
                    $("#overlay").fadeOut("fast");
                },
				success: function(response){
					$("#overlay").fadeOut("fast", function(){
						$.getJSON("/manager/files", function(data)
						{
							get_files(data);
						});
                        $(".fileItem").fadeOut("fast");
						Messenger().post("file \"" + file + "\" has just been deleted!");
					});
				}
			});
		}
	});
	
	$("#fileSaveBtn").on("click", function(e){
		var file = $(this).attr("data-path");
		
		$("#overlay").fadeIn("fast");
		$.post("/upload/save", {
			"file": file,
			"fileContent": editor.getValue().trim()
		}, function(response){
			if (response == "success")
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("file \"" + file + "\" has just been saved!");
			}
			else
			{
				$("#overlay").fadeOut("fast");
				Messenger().post("we were unable to save file \"" + file + "\" at the moment!");
			}
		}).error(function(){
            $("#overlay").fadeOut("fast");
            Messenger().post("Cannot contact server!");
        });
	});
	
	$(".css-treeview").on("click", ".file", function(e){
		e.stopPropagation();
		
		var id = $(this).attr("data-id");
		var cat = $(this).attr("parent-id");
		var path = $(this).attr("data-path");
		var extension = get_file_extension(path);

		if (!$(this).hasClass("upload"))
		{
			if ($.inArray(extension,["png","jpg","jpeg","gif"]) >= 0)
			{
				showContent($(this),path,"viewer",cat);
			}
            else if ($.inArray(extension,["pdf","zip","rar"]) >= 0)
            {
                Messenger().post("No preview available");
            }
			else
			{
				$("#fileSaveBtn").attr("data-path",$(this).attr("data-path"));
				showContent($(this),id,"editor",extension);
			}
		}
	});
	
	
	$(".newFolder").on("click", function(e){
		$(this).val("");
	}).on("blur", function(e){
		if ($(this).val().length == 0)
			$(this).val("[new folder]");
	});
	
	$(".css-treeview").on("click", ".upload", function(e){
		// reset upload form each time upload is clicked
		$("#fileUpload").each(function(){this.reset();});
		
		var path = "", pathArray = new Array();
		var paths = $(this).parents("ul");
		
		for (var i = 0; i < paths.length - 1; i++)
		{
            pathArray.push($($(paths[i]).prev()).text());
            console.log($($(paths[i]).prev()).text());
		}

        pathArray = pathArray.reverse();
        // console.log("/" + pathArray.join('/'));

		$("#filePath").val("/" + pathArray.join('/'));
		$("#fileUpload_datafile").click();
	});
	
	$("#fileUpload_datafile").on("change", function(e){
		var ext = $('#fileUpload_datafile').val().split('.').pop().toLowerCase();
		var category = ext;
		var path = $("#filePath").val();
		$("#fileCategory").val(ext);

		if($.inArray(ext, ["css","js","png","jpg","jpeg","gif", "pdf", "zip", "rar"]) > -1)
		{
			$("#fileUpload").submit();
		}
		else 
		{
			$("#fileUpload").each(function(){this.reset();});
			Messenger().post("\"" + ext + "\" is an invalid extension");
		}
	});

    $("#codeCleanupBtn").on("click", function(e){
        autoFormatSelection(editor);
    });
	
});