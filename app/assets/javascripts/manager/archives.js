function loadListOfArchivedItems(page) {
    $.getJSON("/manager/h/archived/" + page, function(response)
    {
        var count = 0;
        if (response.status == "success")
        {
            var items = response.data;

            $($("#tblArchives tbody:first").find("tr:not(:first)")).remove();

            if (response.extra.max > 1)
            {
                if (response.extra.cur == response.extra.max)
                {
                    $($(".navNext").parent()).addClass("disabled");
                    $($(".navPrevious").parent()).removeClass("disabled");
                } else
                {
                    $($(".navNext").parent()).removeClass("disabled");
                    $($(".navPrevious").parent()).addClass("disabled");
                }
            } else
            {
                $($(".navNext").parent()).addClass("disabled");
                $($(".navPrevious").parent()).addClass("disabled");
            }

            for (var i = 0; i < items.length; i++)
            {
                count++;

                var cloned = $("#archivesDummyItem").clone();

                $(cloned.find("td:first")).attr("data-id",items[i].id);
                $(cloned.find("td:first")).text(items[i].id);
                $(cloned.find("td:eq(2)")).text(items[i].key);
                $(cloned.find("td:eq(3)")).text(items[i].value);
                if (items[i].hide)
                    $($(cloned.find("td:eq(1)")).find(".permaDeleteItem")).hide();
                cloned.removeAttr("id");

                $($("#tblArchives").find("tbody:first")).append(cloned);
                cloned.show();
            }

            if (response.extra.max > 0)
                $(".navCurrentPage").text(response.extra.cur);
            else
                $(".navCurrentPage").text("0");
            $(".navMaxPage").text(response.extra.max);
        } else
        {
            Messenger().post("failed to load data");
        }
    }).error(function(){
        Messenger().post("unable to contact server");
    });
}

$(function(){

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    loadListOfArchivedItems(1);

    $("#tblArchives").on("click", ".permaDeleteItem", function(e){
        $("#permaDeleteProceedBtn").attr("data-id", $($($(this).parent()).prev()).attr("data-id"));
    });

    $("#tblArchives").on("click", ".recycleItem", function(e) {
        $("#recycleProceedBtn").attr("data-id", $($($(this).parent()).prev()).attr("data-id"));
    });

    $("#permaDeleteProceedBtn").on("click", function(e){
        var $obj = $("#permaDeleteApproval");
        var approval = $obj.val();

        if (approval.length == 0)
        {}    // Do nothing
        else
        {
            if (approval != "delete")
            {
                // Do nothing
            } else
            {
                var id = $(this).attr("data-id");
                $.ajax({
                    url: "/manager/configurations/purge/" + id,
                    cache: false,
                    type: "DELETE",
                    beforeSend: function(){
                        $("#permaDeleteProceedBtn").text("purging data...");
                        $("#permaDeleteCancelBtn").attr("disabled","disabled");
                        $("#permaDeleteProceedBtn").attr("disabled","disabled");
                    },
                    error: function(){
                        $("#permaDeleteProceedBtn").text("proceed");
                        $("#permaDeleteCancelBtn").removeAttr("disabled");
                        $("#permaDeleteProceedBtn").removeAttr("disabled");
                    },
                    success: function(response){
                        $("#permaDeleteProceedBtn").text("proceed");

                        if (response.status == "success")
                        {
                            $("#permaDeleteModal").modal("hide");
                            loadListOfArchivedItems(parseInt($(".navCurrentPage").text()));
                            Messenger().post("data of item are purged successfully");
                        } else
                        {
                            Messenger().post("data of item are not purged");
                            $("#permaDeleteCancelBtn").removeAttr("disabled");
                            $("#permaDeleteProceedBtn").removeAttr("disabled");
                        }
                    }
                });
            }
        }
    });

    $("#permaDeleteModal").on("shown", function(){

    });

    $("#permaDeleteModal").on("hidden", function(){
        $("#permaDeleteProceedBtn").text("proceed");
        $("#permaDeleteProceedBtn").removeAttr("data-id");
        $("#permaDeleteApproval").val("");
        $("#permaDeleteCancelBtn").removeAttr("disabled");
        $("#permaDeleteProceedBtn").removeAttr("disabled");
    });

    $("#recycleProceedBtn").on("click", function(e){
        var $obj = $("#permaRecycleApproval");
        var approval = $obj.val();

        if (approval.length == 0)
        {}    // Do nothing
        else
        {
            if (approval != "recycle")
            {
                // Do nothing
            } else
            {
                var id = $(this).attr("data-id");
                $.ajax({
                    url: "/manager/configurations/restore/" + id,
                    cache: false,
                    type: "POST",
                    beforeSend: function(){
                        $("#recycleProceedBtn").text("restoring...");
                        $("#recycleCancelBtn").attr("disabled","disabled");
                        $("#recycleProceedBtn").attr("disabled","disabled");
                    },
                    error: function(){
                        $("#recycleProceedBtn").text("proceed");
                        $("#recycleCancelBtn").removeAttr("disabled");
                        $("#recycleProceedBtn").removeAttr("disabled");
                    },
                    success: function(response){
                        $("#recycleProceedBtn").text("proceed");

                        if (response.status == "success")
                        {
                            $("#recycleModal").modal("hide");
                            loadListOfArchivedItems(parseInt($(".navCurrentPage").text()));
                            Messenger().post("data of item are restored successfully");
                        } else
                        {
                            Messenger().post("data of item are not restored");
                            $("#recycleCancelBtn").removeAttr("disabled");
                            $("#recycleProceedBtn").removeAttr("disabled");
                        }
                    }
                });
            }
        }
    });

    $("#recycleModal").on("shown", function(){

    });

    $("#recycleModal").on("hidden", function(){
        $("#recycleProceedBtn").text("proceed");
        $("#recycleProceedBtn").removeAttr("data-id");
        $("#permaRecycleApproval").val("");
        $("#recycleCancelBtn").removeAttr("disabled");
        $("#recycleProceedBtn").removeAttr("disabled");
    });

    $(".navPrevious").on("click", function(e){
        if ($($(this).parent()).hasClass("disabled"))
            e.preventDefault();
        else
        {
            var page = parseInt($(".navCurrentPage").text());
            loadListOfArchivedItems(page - 1);
        }
    });

    $(".navNext").on("click", function(e){
        if ($($(this).parent()).hasClass("disabled"))
            e.preventDefault();
        else
        {
            var page = parseInt($(".navCurrentPage").text());
            loadListOfArchivedItems(page + 1);
        }
    });

    $(".navFirst").on("click", function(){
        loadListOfArchivedItems(1);
    });

    $(".navLast").on("click", function(){
        var page = parseInt($(".navMaxPage").text());
        loadListOfArchivedItems(page);
    });

});
