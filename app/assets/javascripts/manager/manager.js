var const_key_regex = /^[a-zA-Z0-9\-\/]+$/i;

var change_count = 0;
var row_deleted = new Array();

window.onbeforeunload = function(){
	if (change_count > 0)
		return "There are unsaved changes. Are you sure?";
	else
		return;
}

function reloadViewonCreateMetadata(){
	var trs = $($("#configTable tbody").first()).find("tr");
	for (var i = 0; i < trs.length; i++)
	{
		if (i > 0)
			$(trs[i]).fadeIn("fast");
	}
}

function createMetadata(){
	key_good = true;

	// If key is good, proceed
	if (key_good) {
		$.post("/manager/configurations", {
			"key": $("#txtNewKey").val(),
			"value": $("#txtNewValue").val(),
			"cat": $("#selectNewCat").val(),
			"mime" : $("#selectNewMime").val()
		}, function(response){
			if (response.status == "success")
			{
				Messenger().post("Item [" + response.data.newid + "] has just been created and added!");
			
				var item = $("#tr_sample").clone();
				$(item).css("display","table-row");
				$(item).attr("data-id",response.data.newid);
				var tds = $(item).find("td");
				$(tds[0]).text(response.data.newid);
				$($(tds[1]).find("span").first()).text($("#txtNewKey").val());
				$($(tds[2]).find("span").first()).text($("#txtNewValue").val());
				$($(tds[3]).find("span").first()).text($("#selectNewCat").val());
				
				//add to table
				$($("#configTable tbody").first()).append(item);
			} else
				//alert("We're unable to do that at the moment due to " + response.message);
				Messenger().post("We're unable to do that at the moment due to a problem!");
		}).error(function(){
            Messenger().post("Cannot contact server!");
        });
	}
}

function updateMetadata(elem, id, obj){
    console.log(obj);
	$.ajax({
		url: '/manager/configurations/'+id,
		type: 'PUT',
		data: {
			"data": obj
		},
        error: function(){
            Messenger().post("Cannot contact server!");
        },
		success: function(response) {
			console.log(response.status);
			if (response.status == "success")
			{
				Messenger().post("Item [" + id + "] has just been updated!");
			
				var elemParent = $(elem).parent();
				var elemSpan = $(elemParent).find("span").first();
				$(elemParent).css("max-height","408px");
				$(elemParent).css("height","auto");
				$(elemSpan).text($(elem).val());
				$(elem).hide();
				$(elemSpan).fadeIn("fast");
				$($(elem).parents()[0]).css("overflow","auto");
				change_count--;
			} else
				//alert("We're unable to do that at the moment due to " + response.message);
				Messenger().post("We're unable to do that at the moment due to a problem!");
		}
	});
}

function deleteCheckItems(){
	if (row_deleted.length == 0)
	{
		$("#deleteMsg").text("Nothing to do!");
		$("#deletebtn").attr("disabled","disabled");
		return;
	} else
	{
		$("#deleteMsg").text("Are you sure you want to delete it/them?");
		$("#deletebtn").removeAttr("disabled");
	}
}

function deleteMetadata()
{
	for (var i = 0; i < row_deleted.length; i++)
	{
		//console.log(row_deleted[i]);
		
		changes_deleted = $("tr[data-id=" + row_deleted[i].toString() + "] .input:visible").length;
		var delId = row_deleted[i];

		$.ajax({
		    url: '/manager/configurations/'+row_deleted[i],
		    type: 'DELETE',
            error: function(){
                Messenger().post("Cannot contact server!");
            },
		    success: function(response) {
		        if (response.status == "success")
		        {
		        	Messenger().post("Item [" + response.data.id  + "] has just been deleted!");
		        
			        var elemTbody = $("#configTable tbody").first();
			        var trs = $(elemTbody).find("tr");
			        
			        //console.log(trs.length);
			        
			        $(trs).each(function(index){
			        	var tds = $(this).find("td");
			        	
			        	//console.log(parseInt($(tds[0]).text()) + "|" + parseInt(response.data.id));
			        	if (parseInt($(tds[0]).text()) == parseInt(response.data.id))
			        		$(this).remove();
			        });
			        
			        change_count -= changes_deleted;
		        } else
				//alert("We're unable to do that at the moment due to " + response.message);
					Messenger().post("We're unable to do that at the moment due to a problem!");
		    }
		});
	}
	
	row_deleted.length = 0;
}

$(function(e){
	
	Messenger.options = {
		extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
		theme: 'air'
	};
	
	$("#configTable").on("click","td", function(){
		var elem = $(this).find(".input[data-attr=editor]").first();
		var elemSpan = $(this).find("span").first();
		var elemDiv = $(this).find("div").first();
		
		$(elemDiv).css("max-height","408px");
		$(elemDiv).css("height","408px");
		$(elemDiv).css("overflow","hidden");
		
		if (!$(elem).is(":visible") && $(this).attr("data-attr") != "selector")
		{
			$(elemSpan).hide();
			$(elem).val($.trim($(elemSpan).text()));
			$(elem).fadeIn("fast");
			$(elem).focus()
			
			change_count++;
			//console.log(change_count);
		}
		
		if ($(this).attr("data-attr") == "selector")
		{
			if (!$($(this).parent()).hasClass("warning"))
			{
				$($(this).parent()).addClass("warning");
				
				
				if (row_deleted.indexOf($(this).text()) < 0)
					row_deleted.push($(this).text());
				
				//console.log(row_deleted);
			}
			else
			{
				$($(this).parent()).removeClass("warning");
				
				var deleted_index = -1;
				if ((deleted_index = row_deleted.indexOf($(this).text())) >= 0)
					row_deleted.splice(deleted_index,1);
				
				//console.log(row_deleted);
			}
		}
	});
	
	$("#configTable").on("keyup", ".input[data-attr=editor]", function(e){
		//alert(e.keyCode);
		if (e.keyCode == 192 && e.ctrlKey)
		{
			//console.log($($(this).parents()[1]).html());
			if (!const_key_regex.test($(this).val()) && $($(this).parents()[1]).attr("data-attr") != "nocheck")
			{
				//console.log("Invalid data!");
				$($(this).parents()[2]).addClass("error");
				return;
			}
			
			if ($($(this).parents()[2]).hasClass("error"))
				$($(this).parents()[2]).removeClass("error")
			
			var elemParent = $(this).parents()[1];
			var updateElement = $($(elemParent).parent().find("td"));
			var updateId = $(updateElement[0]).text();
            var updateValue = "";
            var updateObj = {};

            if ($($($(elemParent).find("div")).first()).has("input[type=text]").length > 0)
            {   updateValue = $($($($(elemParent).find("div")).first()).find("input[type=text]")[0]).val().trim();
                updateObj = {
                    "key" : updateValue
                };
            }
            else if ($($($(elemParent).find("div")).first()).has("textarea").length > 0)
            {
                updateValue = $($($($(elemParent).find("div")).first()).find("textarea")[0]).val().trim();
                updateObj = {
                    "value" : updateValue
                };
            }
			
			updateMetadata($(this),updateId,updateObj);
		}
	}).on("change", ".input[data-attr=editor]", function(e){	
		
		if ($(this).is("select"))
		{
			var elemParent = $(this).parent();
			var updateElement = $($(elemParent).parent().find("td"));
			var updateId = $(updateElement[0]).text();
            var updateValue = $($(elemParent).find("select").first()).val();

			var updateObj = {
				"cat" : updateValue
			}

            console.log(updateObj);
			
			updateMetadata($(this),updateId,updateObj);
		}
	});
	
	$("#txtNewKey").on("keyup", function(e){
		var value = $(this).val();
		console.log(value);
		
		// Validate key
		if (!const_key_regex.test(value) || value.length == 0)
		{
			if (value.length > 0)
				$(this).css("background-color","#f2dede");
			else
				$(this).css("background-color","transparent");
			$("#createbtn").attr("disabled","disabled");
		} else {
			$(this).css("background-color","transparent");
			$("#createbtn").removeAttr("disabled");
		}
	});
	
	$("#txtFilter").on("keyup", function(){
	  	var query = $(this).val();

	  	var trs = $($("#configTable tbody").first()).find("tr").slice(1);
	  	
	  	$(trs).stop().fadeOut("fast");
	  	for (var i = 0; i < trs.length; i++)
	  	{
	  		var type = $($($(trs[i]).find("td")[3]).find("span").first()).text().trim();
		  	
	  		if (type.indexOf(query) >= 0)
	  		{
		  	   $(trs[i]).fadeIn("fast");
		  	}
	  	}
	});
	
});