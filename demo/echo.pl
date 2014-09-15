use lib '../src/';
use Webqq::Client;
use Webqq::Message;
use Digest::MD5 qw(md5_hex);

#程序默认输出的是UTF8编码，你的终端可能是其他编码，
use Encode::Locale;
use Encode;

my $qq = 12345678;
my $pwd = md5_hex('your password');
my $client = Webqq::Client->new(debug=>0);
$client->login( qq=> $qq, pwd => $pwd);

#设置全局默认的发送消息后的回调函数，主要用于判断消息是否成功发送
$client->on_send_message = sub{
    my ($msg,$is_success,$status) = @_;
    ##程序默认输出的是UTF8编码，你的终端可能是其他编码，做下自适应
    print encode("console_out",decode("utf8",join "","msg_id: ",$msg->{msg_id}," ",$status,"\n") );
};

#设置接收到消息后的回调函数
$client->on_receive_message = sub{
    #传递给回调的参数是一个包含接收到的消息的hash引用
    #$msg = {
    #    type        => message|group_message 消息类型
    #    msg_id      => 系统生成的消息id
    #    from_uin    => 消息发送者uin，回复消息时需要用到
    #    to_uin      => 消息接受者uin，就是自己的qq
    #    content     => 消息内容，采用UTF8编码
    #    msg_time    => 消息的接收时间
    #}
    my $msg = shift;
    
    if($msg->{type} eq 'message'){
        $client->send_message(
            #使用create_msg生成一个消息，设置发送者和消息内容 
            $client->create_msg( to_uin=>$msg->{from_uin},content=>$msg->{content}  )
        ) ;
    }
    elsif($msg->{type} eq 'group_message'){
        $client->send_group_message(
            #使用create_group_msg生成一个群消息，设置发送者和消息内容为接收到的群和群消息
            $client->create_group_msg( to_uin=>$msg->{from_uin},content=>$msg->{content}  )
        ) ;        
    }
};
$client->run;
