local config = 
{
    mysql_db = { host = "127.0.0.1", port = 3306, database = "unity_fun", user = "root", password = "1234", },
	gate_server = { ip = "127.0.0.1", port = 9000, },
    game_server = 
    {
        [1000] = { id = 1000, ip = "127.0.0.1", port = 9001, name = "风华正茂", },
        --[2000] = { id = 2000, ip = "127.0.0.1", port = 9002, name = "老当益壮", },
    },
}

return config


