$.getJSON('./BrightID.json', function(data) {
    brightIDabi = data.abi;
    console.log(brightIDabi);
});

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
        var userAddress = $("#getScore_userAddress").val();
        var contextName = $("#getScore_contextName").val();
        BrightID.getScore(userAddress, contextName, function(error, result){
            if(!error) {
                show(result);
            }
            else{
                console.error(error);
            }
        });
    });

});
