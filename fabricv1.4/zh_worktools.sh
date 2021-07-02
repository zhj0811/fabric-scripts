#!/bin/bash

#set -x

#NODES=(0 2)
NODES=(0)

export CORE_PEER_TLS_ENABLED=true
#export BCCSP_CRYPTO_TYPE=GM

#如果要用到TLS 方式,则不能用IP方式,由于证书里面和域名有关
#应该在 /etc/hosts 里面添加所有的 域名 和 IP 的映射
    ORG1_PEER0="peer0.org1.example.com:7051"
    ORG1_PEER1="peer1.org1.example.com:8051"
    ORG2_PEER0="peer0.org2.example.com:9051"
    ORG2_PEER1="peer1.org2.example.com:10051"
    ORDERADDRESS="orderer.example.com:7050"

TEMPID=$3

CHANNEL_NAME="mychannel"
#如果是动态增加channel，请将CHANNEL_NAME的变量设置为"channel1"
CCNAME="mycc"
CCVERSION=$2
: ${CCVERSION:=1.0}
#PROJECT=factoring
#PROJECT=ic-register
PROJECT=fabric-normal
#CCPATH="github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd"
#COMPANY=jzsg
COMPANY=zhj0811
CCPATH="github.com/$COMPANY/$PROJECT/chaincode"
#CCPATH="github.com/chaincodes/simple"
#CCPATH="/home/zh/gopath/src/github.com/chaincodes/simple"
#CCPATH="github.com/peersafe/aiwan/fabric/chaincode"
CCPACKAGE="$PROJECT.out"
INITARGS='{"Args":["init","a","100","b","200"]}'
#TESTARGS1='{"Args":["query","b"]}'
TESTARGS1='{"Args":["QueryData","test"]}'
#TESTARGS2='{"Args":["invoke","a","b","1"]}'
TESTARGS2='{"Args":["SaveData","{\"docType\":\"test\",\"owner\":\"zha\",\"key\":\"2\"}"]}'
#TESTARGS='{"Args":["RegisterUser","b","1"]}'
#TESTARGS='{"Args":["DslQuery","trackid","{\"dslSyntax\":\"{\\\"selector\\\":{\\\"sender\\\":\\\"zhengfu0\\\"}}\"}"]}'
#TESTARGS='{"Args":["GetBidListByDsl","trackid","{\"reqArgs\":\"{\\\"selector\\\":{\\\"docType\\\":\\\"bidDoc\\\"}}\"}"]}'

ORDERER_CA="$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
#POLICY="OR  ('Org1MSP.peer','Org2MSP.peer')"
POLICY="OR  ('Org1MSP.member','Org2MSP.member')"

export PATH=$PATH:$PWD/peertool/linux-amd64/bin
#BINPATH=$(which peer | xargs dirname)
export FABRIC_CFG_PATH=$PWD/peertool/sampleconfig
export GODEBUG=netdns=go
echo "=================== NOTICE ==================="
LOCAL_VERSION=$(peer version | sed -ne 's/ Version: //p'| head -1)
echo "============Local ENV Version $LOCAL_VERSION============"
echo "============BCCSP CRYPTO TYPE Version $BCCSP_CRYPTO_TYPE============"
echo "==============================================="
if [[ "$0" =~ "gene" ]]; then
    return
fi
setGlobals () {
    if [ $1 -eq 0 -o $1 -eq 1 ] ; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

    export CORE_PEER_TLS_CLIENTAUTHREQUIRED=false
    export CORE_PEER_TLS_CLIENTROOTCAS_FILES=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_TLS_CLIENTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    export CORE_PEER_TLS_CLIENTKEY_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
        if [ $1 -eq 0 ]; then
          export CORE_PEER_ADDRESS=$ORG1_PEER0
        else
          export CORE_PEER_ADDRESS=$ORG1_PEER1
        fi
    else
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
    CORE_PEER_TLS_CLIENTROOTCAS_FILES=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    CORE_PEER_TLS_CLIENTCERT_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
    CORE_PEER_TLS_CLIENTKEY_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key

        if [ $1 -eq 2 ]; then
            CORE_PEER_ADDRESS=$ORG2_PEER0
        else
            CORE_PEER_ADDRESS=$ORG2_PEER1
        fi
    fi
    export CORE_PEER_TLS_ROOTCERT_FILE
    #export CORE_PEER_TLS_CERT_FILE
    #export CORE_PEER_TLS_KEY_FILE
    export CORE_PEER_LOCALMSPID
    export CORE_PEER_MSPCONFIGPATH
    export CORE_PEER_ADDRESS
#    export CORE_PEER_TLS_CLIENTAUTHREQUIRED
#    export CORE_PEER_TLS_CLIENTROOTCAS_FILES
#    export CORE_PEER_TLS_CLIENTCERT_FILE
#    export CORE_PEER_TLS_CLIENTKEY_FILE
    env | grep CORE
}

1_SetConfig (){
    echo "*******************creat channel****************************"
    which peer
    setGlobals 0
    set -x
    peer channel create -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --tls true --cafile $ORDERER_CA
    set +x

    echo "*******************all peer join channel*************************"

    for ch in ${NODES[*]}; do
        setGlobals $ch
        peer channel join -b $CHANNEL_NAME.block
        echo "===================== PEER$ch joined on the channel \"$CHANNEL_NAME\" ===================== "
        sleep 2
        echo
    done
    echo "*****************org1 and org2  update anchorPeer**************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        peer channel update -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    done
}

2_Deploy () {
    if [ "$CCVERSION" == "" ]; then
        echo "***********2_Deploy error eg: ./deployCC.sh 2 1.0**************"
        exit 1
    fi

    which peer

#    echo "************************creat  chaincode package******************"
#    setGlobals 0
#    peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

    echo "******************all peers install chaincode by package method***********"
    for ch in ${NODES[*]}; do
       setGlobals $ch
        peer chaincode install $CCPACKAGE
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done

#    # from code
#    echo "************all peers install chaincode by path method*********"
#    for ch in ${NODES[*]}; do
#        setGlobals $ch
#	set -x
#        peer chaincode install -n $CCNAME -v $CCVERSION -p $CCPATH
#	set +x
#        echo "===================== PEER$ch install ===================== "
#        sleep 2
#        echo
#    done

    echo "*******************instantiate chaincode only need one org*********************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        peer chaincode instantiate -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        echo "===================== PEER$ch instantiate ===================== "
    done
    echo "***************test is chaincode depoly success!********************"
    #peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
}

3_Upgrade () {
    echo "**********************creat  chaincode package*******************"
    if [ "$CCVERSION" == "" ]; then
        echo "3_Upgrade error eg: ./deployCC.sh 3 1.1"
        exit 1
    fi

    setGlobals 0
    peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

#    echo "*********************all peers install chaincode by package method******************"
#    for ch in 0; do
#        setGlobals $ch
#        peer chaincode install $CCPACKAGE
#        echo "===================== PEER$ch install ===================== "
#        sleep 2
#        echo
#    done
    # from code
    echo "all peers install chaincode by path method"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        peer chaincode install -n $CCNAME -v $CCVERSION -p $CCPATH
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done

    echo "*********************upgrade chaincode ******************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
            peer chaincode upgrade -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        else
           peer chaincode upgrade -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        fi
    done
    echo "test is chaincode depoly success!"
}

4_Test () {
    echo "************************Test Query******************"
    setGlobals 0
    #peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS1 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS1 --tls true
    peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS2 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

5_MakePackage () {
    echo "************************creat  chaincode package******************"
    rm -rf $CCPACKAGE
    setGlobals 0
    set -x
    peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE
    set +x
}

6_CouchDBSetIndex () {
    echo "*********************CouchDB Set Sort Index****************"
    for ch in 5 6 7 8; do
        echo `curl -i -X POST -H "Content-Type: application/json" -d              \
        "{\"index\":{\"fields\":[{\"data.createTime\":\"asc\"}]},                 \
        \"ddoc\":\"indexCreateTimeSortDoc\",\"name\":\"indexCreateTimeSortDesc\", \
        \"type\":\"json\"}" http://localhost:{$ch}984/$CHANNEL_NAME/_index`
    echo "=====================CoucdDB localhost:'$ch'984 setIndex success! ===================== "
    done
}
7_fetchBlock () {
    #Use orderer's MSP for fetching system channel config block
    echo $1
    if [ "$1" == "testchainid" ]; then
        echo "fetch testchianid"
        CHANNEL_NAME=$1
        CORE_PEER_LOCALMSPID="OrdererMSP"
	    CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
	    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp
	    export CORE_PEER_LOCALMSPID
	    export CORE_PEER_TLS_ROOTCERT_FILE
	    export CORE_PEER_MSPCONFIGPATH
    else
        setGlobals 0
    fi
    echo $CHANNEL_NAME
    peer channel fetch newest ${CHANNEL_NAME}_block.pb -o $ORDERADDRESS -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}


FetchChannelConf (){
  if [ "$1" == "testchainid" ]; then
    CHANNEL_NAME=$1
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
    export CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp
  else
    setGlobals 0
  fi
  set -x
  which peer
  which configtxlator
  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
  configtxlator proto_decode --input config_block.pb --type common.Block |jq .data.data[0].payload.data.config > config.json
  set +x
}


if [ $1 -eq 1 ]; then
    1_SetConfig
elif [ $1 -eq 2 ]; then
    2_Deploy
elif [ $1 -eq 3 ]; then
    3_Upgrade
elif [ $1 -eq 4 ]; then
    4_Test
elif [ $1 -eq 5 ]; then
    5_MakePackage
elif [ $1 -eq 6 ]; then
    6_CouchDBSetIndex
elif [ $1 -eq 7 ]; then
    7_fetchBlock $2
elif [ $1 -eq 8 ]; then
  FetchChannelConf $2
else
    echo "Command Error  channel   eg: ./worktool.sh 1"
    echo "Command Error  deploy cc        eg: ./worktool.sh 2 1.0"
    echo "Command Error  upgrade cc      eg: ./worktool.sh 3 1.1"
    echo "Command Error  test cc          eg: ./worktool.sh 4"
    echo "Command Error  only make package   eg: ./worktool.sh 5 1.0"
    echo "Command Error  couchdb set sortIndex   eg: ./worktool.sh 6"
    echo "Command Error  fetch block  eg: ./worktool.sh 7 testchainid"
    exit
fi

