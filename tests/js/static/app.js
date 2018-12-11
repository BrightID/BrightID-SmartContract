brightIDabi = JSON.parse('[{"constant":false,"inputs":[{"name":"contextName","type":"bytes32"},{"name":"nodeAddress","type":"address"}],"name":"removeNodeFromContext","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"nodeAddress","type":"address"}],"name":"isNode","outputs":[{"name":"ret","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"userAddress","type":"address"}],"name":"isUser","outputs":[{"name":"ret","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"contextName","type":"bytes32"},{"name":"nodeAddress","type":"address"}],"name":"addNodeToContext","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"contextName","type":"bytes32"}],"name":"removeContext","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"contextName","type":"bytes32"}],"name":"isContext","outputs":[{"name":"ret","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"userAddress","type":"address"},{"name":"contextName","type":"bytes32"}],"name":"getScore","outputs":[{"name":"","type":"uint32"},{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"nodeAddress","type":"address"}],"name":"addNode","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"contextName","type":"bytes32"},{"name":"nodeAddress","type":"address"}],"name":"isNodeInContext","outputs":[{"name":"ret","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"nodeAddress","type":"address"}],"name":"removeNode","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"contextName","type":"bytes32"}],"name":"addContext","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"userAddress","type":"address"},{"name":"contextName","type":"bytes32"},{"name":"score","type":"uint32"},{"name":"timestamp","type":"uint32"},{"name":"r","type":"bytes32"},{"name":"s","type":"bytes32"},{"name":"v","type":"uint8"}],"name":"setScore","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"userAddress","type":"address"},{"indexed":false,"name":"contextName","type":"bytes32"},{"indexed":false,"name":"score","type":"uint32"},{"indexed":false,"name":"timestamp","type":"uint32"}],"name":"LogSetScore","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"nodeAddress","type":"address"}],"name":"LogAddNode","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"nodeAddress","type":"address"}],"name":"LogRemoveNode","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"contextName","type":"bytes32"}],"name":"LogAddContext","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"contextName","type":"bytes32"}],"name":"LogRemoveContext","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"contextName","type":"bytes32"},{"indexed":false,"name":"nodeAddress","type":"address"}],"name":"LogAddNodeToContext","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"contextName","type":"bytes32"},{"indexed":false,"name":"nodeAddress","type":"address"}],"name":"LogRemoveNodeFromContext","type":"event"}]')

function show(result) {
    $('#result').html(String(result));
    modal.open();
}

window.addEventListener('load', async () => {
    modal = M.Modal.init($('#modal1'))[0];
    $('#contract_address').blur(function() {
        var BrightIDContract = web3.eth.contract(brightIDabi)
        BrightID = BrightIDContract.at($(this).val());
        try {
            BrightID.isContext('Aragon', function(error, result) {
                if (error) {
                    show('This is not a BrightID smart contract address!');
                }
            });
        } catch (e) {
            show('Invalid Smart Contract Address!');
        }
    });
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send;
            await ethereum.enable();
        } catch (error) {
            console.log('User denied account access...');
        }
    }
    else if (window.web3) {
        window.web3 = new Web3(web3.currentProvider);
    }
    else {
        console.log('You should consider trying MetaMask!');
    }
    web3.eth.defaultAccount = web3.eth.accounts[0];


    $("#signScore").click(function() {
        var userAddress = $("#setScore_userAddress").val();
        var contextName = $("#setScore_contextName").val();
        var score = $("#setScore_score").val();
        $.ajax({
            type: "POST",
            url: '/sign_score',
            data: {"userAddress":userAddress, "score":score},
            success: function(data) {
                console.log(data['timestamp']);
                console.log(data['r']);
                console.log(data['s']);
                console.log(data['v']);

                BrightID.setScore(userAddress, contextName, score, data['timestamp'], data['r'], data['s'], data['v'], function(error, result){
                    if(!error) {
                        show(result);;
                    }
                    else{
                        console.error(error);
                    }
                });
            },
            dataType: "json"
        });
    });

    $("#getScore").click(function() {
        var userAddress = $("#setScore_userAddress").val();
        var contextName = $("#setScore_contextName").val();
        BrightID.getScore(userAddress, contextName, function(error, result){
            if(!error) {
                show(result);;
            }
            else{
                console.error(error);
            }
        });
    });

});
