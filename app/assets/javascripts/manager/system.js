var const_key_regex = /^[a-zA-Z0-9]+$/i;
var const_value_regex = /^[0-9]+$/i
var systemConfig_forbiddens = ["fc7b6dd684ea01a1c1a77d28f279fbb47f66174433e31911445242417cab5e8f", "98ba95570d71c6941de273d56ebfcc3d02c22573b1110fd67903e82ae10d45d3", "81211a6d9ebc8637924de76d7c270a59a6d281b614c9883125c9aff99efca934", "cb5f7ea001c32777cbf38e8eb84ee11dbd95ff58586f8754caf61c930d46d71c", "1291b64e8de47bbfaea6cfd2cd6c06e7db47f1aebe98db22f6664f56c2b56f1d"];

$(function () {
    var curListOfAppsFromWorkspace = []
    var curTab = null;

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $("#configTable tbody:first").on("change", ".systemCellEditable input[type=text]", function (e) {
        e.stopPropagation();

        //var span = $($(this).find("span:first"));
        //var input = $($(this).find("input[type=text]:first"));
        var parent = $(this).parents("tr").first();

        var updateId = $($(parent).find("td")[0]).attr("data-id");
        var updateObj = {
            "value": $(this).val()
        }

        $.ajax({
            url: "/manager/configurations/" + updateId,
            data: {
                "data": updateObj
            },
            type: "put",
            cache: "false",
            beforeSend: function () {

            },
            error: function () {
                Messenger().post("Cannot contact server!");
            },
            success: function (response) {
                if (response.status == "success") {
                    Messenger().post("Configuration value has just been updated");
                }
                else {
                    Messenger().post("it is unable to be modified at the moment");
                }
            }
        });

    });

    $("a[data-toggle=\"tab\"]").on("shown", function (e) {
        var targetId = $(e.target).attr("href").replace("#", "");
        curTab = targetId;

        switch (targetId) {
            case "systemConfig":
                // Ask server to return a list of configuration data item
                $("#systemConfigTabLoadingText").fadeIn("fast");
                $.getJSON("/manager/s/items/list/config",function (response) {
                    $("#configTable tbody:first tr:not(:first)").remove();
                    for (var i = 0; i < response.length; i++) {
                        var cloned = $("#configTableDummy").clone();
                        $($(cloned).find("td")[0]).attr("data-id", response[i].id);
                        $($(cloned).find("td")[0]).text((i + 1).toString());
                        $($($(cloned).find("td")[1]).find("span")[0]).text(response[i].key);

                        var shaObj = new jsSHA(response[i].key, "TEXT");

                        if ($.inArray(shaObj.getHash("SHA-256", "HEX"), systemConfig_forbiddens) >= 0) {
                            $($(cloned).find("td")[2]).removeClass("systemCellEditable");
                            $($($(cloned).find("td")[2]).find("input[type=text]")[0]).val("***");
                            $($($(cloned).find("td")[2]).find("input[type=text]")[0]).attr("disabled","disabled");
                        } else
                        {
                            $($($(cloned).find("td")[2]).find("input[type=text]")[0]).val(response[i].value);
                        }

                        $(cloned).removeAttr("style");
                        $(cloned).removeAttr("id");
                        $("#configTable tbody:first").append(cloned);
                    }

                    $("#systemConfigTabLoadingText").fadeOut("fast");
                }).error(function () {
                        $("#systemConfigTabLoadingText").fadeOut("fast");
                    });
                break;
            case "serviceAccountConfig":
                // Don't do anything at the moment
                break;

            default:

        }
    });

    $("#systemTabs a:first").tab("show");

    $("#txtFilter").on("keyup", function() {
        var query = $(this).val();

        var trs = $($("#configTable tbody").first()).find("tr").slice(1);

        $(trs).stop().fadeOut("fast");
        for (var i = 0; i < trs.length; i++)
        {
            var type = $($($(trs[i]).find("td")[1]).find("div span").first()).text().trim();

            if (type.indexOf(query) >= 0)
            {
                $(trs[i]).fadeIn("fast");
            }
        }
    });

    $("#supportedLanguages li").on("click", function(){
        $("#supportedLanguages li").removeClass("active");
        $(this).addClass("active");

        $(".btnOps").hide();

        var dataCode = $(this).attr("data-code");

        $("#supportedCodes li").hide();
        $("#supportedCodes li").removeClass("active");
        $($("#supportedCodes li").filter(function(){
            return $($(this).find("a:first")).text() == dataCode
        })).show();
    });

    $("#supportedCodes li").on("click", function(){
        $("#supportedCodes li").removeClass("active");
        $(this).addClass("active");

        $(".btnOps").hide();

        var selectedSupportedLanguage = $($("#supportedLanguages li").filter(function(){
            return $(this).hasClass("active");
        })).first();

        var selectedSupportedCode = $($("#supportedCodes li").filter(function(){
            return $(this).hasClass("active");
        })).first();

        console.log($($(selectedSupportedLanguage).find("a:first")).text() + " | " + $($(selectedSupportedCode).find("a:first")).text());
        var selectedSupportedLanguageName = $($(selectedSupportedLanguage).find("a:first")).text();
        var selectedSupportedLanguageCode = $($(selectedSupportedCode).find("a:first")).text();

        $("#btnDelete").removeAttr("data-id");

        // Check if locale exists
        $.getJSON("/manager/s/v/" + selectedSupportedLanguageCode +  "/locale", function(response){
            //if (response != undefined && response != null)

            if ($.isEmptyObject(response))
            {
                $("#btnAdd").show();
            }
            else
            {
                $("#btnDelete").attr("data-id", response.id);
                $("#btnDelete").show();
            }
        }).error(function(){
            Messenger().post("Unable to contact server");
        });
    });

    // Language management operations
    $("#btnAdd").on("click", function(e){
        e.stopPropagation();

        var $this = $(this);
        var selectedElem = $("#supportedCodes li").filter(function(index){
            return $(this).hasClass("active");
        });
        var selectedLangElem = $("#supportedLanguages li").filter(function(index){
            return $(this).hasClass("active");
        });

        var key = $(selectedLangElem[0]).text();
        var value = $(selectedElem[0]).text();

        $.post("/manager/configurations",
            {
                'key' : key,
                'value' : value,
                'cat' : 'locale',
                'mime' : 'text/plain'
            }, function(response){
                if (response.status == "success")
                {
                    $this.hide(1, function(){
                        $("#btnDelete").attr("data-id", response.data.newid);
                        $("#btnDelete").show();
                    });
                    Messenger().post("locale is successfully created");
                }
                else
                {
                    Messenger().post("unable to create locale");
                }
            }).error(function(){
                Messenger().post("unable to contact server");
            });
    });

    $("#btnDelete").on("click", function(e){
        e.stopPropagation();

        var $this = $(this);
        var id = $(this).attr("data-id");

        $.ajax({
            url: "/manager/configurations/" + id,
            data: {
                'type' : 'locale'
            },
            cache: false,
            type: "DELETE",
            beforeSend: function(){

            },
            error: function(){
                Messenger().post("unable to contact server");
            },
            success: function(response){
                if (response.status == "success")
                {
                    $this.hide(1 ,function(){
                        $("#btnAdd").show();
                    });
                    Messenger().post("locale is successfully unregistered");
                }
                else
                {
                    Messenger().post("unable to unregister locale");
                }
            }
        })
    });
});