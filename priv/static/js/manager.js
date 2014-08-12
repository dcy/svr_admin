function handle_manager(){
    $('button[data-loading-text]').click(function () {
        var btn = $(this).button('loading');
        //setTimeout(function () {
        //    btn.button('reset');
        //}, 3000);
    });


    is_login = $('#svr-data').data("is_login");
    $("#reload_confs").click(function(){
        console.log("reload_confs");
        if (is_login){
            $.post("/manager/reload_confs",
                   {},
                   function(data){
                       $('#reload_confs').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           $("#errorMsg").html("不能连接服务器, 未开启或者异常!")
                       }
                       else if (result == "success"){
                           $("#errorMsg").html("");
                           location.reload();
                       }
                   }
                  );
        }
        else{
            console.log("not login");
            $('#reload_confs').button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    $("#reload_svr").click(function(){
        if (is_login){
            $.post("/manager/reload_svr",
                   {},
                   function(data){
                       $('#reload_svr').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           $("#errorMsg").html("不能连接服务器, 未开启或者异常!")
                       }
                       else if (result == "success"){
                           $("#errorMsg").html("");
                           location.reload();
                       }
                   }
                  );
        }
        else{
            $('#reload_svr').button('reset');
            $('#loginModal').modal("toggle");
        }
    });
}
