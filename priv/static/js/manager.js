function handle_manager(){

    vex.dialog.buttons.YES.text = '确定';
    vex.dialog.buttons.NO.text = '关闭';

    function vex_alert_error(what) {
        var message = '<div class="text-center text-danger">' + what + '</div>';
        vex.dialog.alert({message: message});
    }

    function vex_confirm(what, callback) {
        var message = '<div class="text-center text-danger">' + what + '</div>';
        vex.dialog.confirm({
            message: message,
            callback: callback
        });
    }

    function msg_sth(something)
    {
        Messenger().post({
            message: something,
            showCloseButton: true
        });
    }


    $('button[data-loading-text]').click(function () {
        var btn = $(this).button('loading');
        //setTimeout(function () {
        //    btn.button('reset');
        //}, 3000);
    });


    is_login = $('#svr-data').data("is_login");
    cur_svr_id = $('#svr-data').data("svr_id");
    console.log("cur_svr_id ", cur_svr_id);
    $("#reload_confs").click(function(){
        console.log("reload_confs");
        if (is_login){
            timestamp = new Date().getTime(),
            $.post("/manager/reload_confs/" + cur_svr_id,
                   {time: timestamp},
                   function(data){
                       $('#reload_confs').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           vex_alert_error("不能连接服务器，服务器未开启或者异常!");
                       }
                       else if (result == "success"){
                           vex_confirm("成功热更", function() {
                               location.reload();
                           });
                       }
                       else {
                           vex_alert_error("数据校验不过: " + result)
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
            timestamp = new Date().getTime(),
                $.post("/manager/reload_svr/" + cur_svr_id,
                   {time: timestamp},
                   function(data){
                       $('#reload_svr').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           vex_alert_error("不能连接服务器，服务器未开启或者异常!");
                       }
                       else if (result == "success"){
                           vex_confirm("成功热更", function() {
                               location.reload();
                           });
                       }
                       else {
                           vex_alert_error("数据校验不过: " + result)
                       }
                   }
                  );
        }
        else{
            $('#reload_svr').button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    $('button[delete-crash-id]').click(function () {
        var crash_id = $(this).attr('delete-crash-id');
        if (is_login){
            $.post("/manager/del_crash",
                   {crash_id: crash_id},
                   function(data) {
                       result = data.result;
                       if (result == "success") {
                           location.reload();
                       }
                   }
                  )
        }
        else {
            $(this).button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    var total_pages = $('#pageInfo').data('total-pages');
    console.log("*****total_pages", total_pages);

    var page_num = $('#pageInfo').data('page-num');


    if ($('#pagination').length > 0) {
        $('#pagination').twbsPagination({
            totalPages: total_pages,
            visiblePages: 6,
            startPage: page_num,
            first: '&laquo;首页',
            last: '最后&raquo;',
            prev: '&lsaquo;前一页',
            next: '后一页&rsaquo;',
            href: '?page={{number}}',
            onPageClick: function (event, page) {
                console.log(page);
                //url = "/game/images/" + game_id + "/" + page;
                //location.href = url;
            }
        });
    }

}
