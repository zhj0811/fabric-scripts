#!/bin/bash

export PATH=$PATH:$PWD/tools/bin
export FABRIC_CFG_PATH=$PWD/tools/config
NODES=(0 2)
#NODES=(0)
#NODES=(0 1 2 3)
CORE_PEER_TLS_ENABLED=true
INITREQUIRED=false

#如果要用到TLS 方式,则不能用IP方式,由于证书里面和域名有关
#应该在 /etc/hosts 里面添加所有的 域名 和 IP 的映射

    ORG1_PEER0="peer0.org1.example.com:7051"
    ORG1_PEER1="peer1.org1.example.com:8051"
    ORG2_PEER0="peer0.org2.example.com:9051"
    ORG2_PEER1="peer1.org2.example.com:10051"
    ORDERADDRESS="orderer.example.com:7050"
    #ORDERADDRESS="orderer2.example.com:8050"
    #ORDERADDRESS="orderer.example.com:7050"


TEMPID=$3

CHANNEL_NAME="mychannel"
#如果是动态增加channel，请将CHANNEL_NAME的变量设置为"channel1"
CCNAME="mycc"
CCVERSION=$2
: ${CCVERSION:=1.0}
#PROJECT=marbles02
PROJECT=fabric-normal
#CCPATH="github.com/hyperledger/fabric-samples/chaincode/marbles02"
#CCPATH="github.com/hyperledger/fabric-samples/chaincode/chaincode_example02"
COMPANY=zhj0811
CCPATH="github.com/$COMPANY/$PROJECT/chaincode"
CCPACKAGE="external-pkg.tar.gz"
#CCPACKAGE="$PROJECT.tar.gz"
CCLABEL="${CCNAME}_1"
#CC_PACKAGE_ID=$CCLABEL:388745f8836bcdb7afc1b65e065d6e3085b7f105028f7f20fb86e02d2e8b1ef2
CC_PACKAGE_ID=$CCLABEL:233be81d469438da1a8537bfddff00a98ffd97a787894b48d4b0870cde219844
#CC_PACKAGE_ID=marbles02_1:844ddc8aed48d2c8e930c806fead93fee9ca3510953c853e8f3d25727affa42b

INITARGS='{"Args":["init","a","100","b","200"]}'
#TESTARGS1='{"Args":["query","b"]}'
TESTARGS1='{"Args":["invoke","b"]}'
TESTARGS2='{"Args":["query","fc0fbc2fb30207aa84cfbc5573324c8bfa35aff4da30e47d5742ba0cc8d2da50"]}'
#TESTARGS2='{"Args":["invoke","a","b","1"]}'
#TESTARGS='{"Args":["RegisterUser","b","1"]}'
#TESTARGS='{"Args":["DslQuery","trackid","{\"dslSyntax\":\"{\\\"selector\\\":{\\\"sender\\\":\\\"zhengfu0\\\"}}\"}"]}'


ORDERER_CA="$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
POLICY="OR  ('Org1MSP.peer','Org2MSP.peer')"
#POLICY="AND  ('Org1MSP.peer','Org2MSP.peer')"
#POLICY="OR  ('Org1MSP.member','Org2MSP.member')"
#POLICY="Org1MSP.peer"

ORG2TLSROOT=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

#BINPATH=$(which peer | xargs dirname)
#export BCCSP_CRYPTO_TYPE=GM
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
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_CERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
    CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
    CORE_PEER_TLS_CLIENTROOTCAS_FILES=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    CORE_PEER_TLS_CLIENTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    CORE_PEER_TLS_CLIENTKEY_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
        if [ $1 -eq 0 ]; then
            CORE_PEER_ADDRESS=$ORG1_PEER0
        else
            CORE_PEER_ADDRESS=$ORG1_PEER1
        fi
    else
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_CERT_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
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
    export CORE_PEER_TLS_CERT_FILE
    export CORE_PEER_TLS_KEY_FILE
    export CORE_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_LOCALMSPID
    export CORE_PEER_TLS_ENABLED
    export CORE_PEER_MSPCONFIGPATH
    export CORE_PEER_ADDRESS
    export CORE_PEER_TLS_CLIENTAUTHREQUIRED
    export CORE_PEER_TLS_CLIENTROOTCAS_FILES
    export CORE_PEER_TLS_CLIENTCERT_FILE
    export CORE_PEER_TLS_CLIENTKEY_FILE
#    env | grep CORE
}

1_SetConfig (){
    echo "*******************creat channel****************************"
    setGlobals 0
  set -x
    peer channel create -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx  --tls --cafile $ORDERER_CA
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

#    echo "************************creat  chaincode package******************"
#    setGlobals 0
#    peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

    echo "******************all peers install chaincode by package method***********"
    for ch in ${NODES[*]}; do
       setGlobals $ch
        set -x
        peer lifecycle chaincode install $CCPACKAGE
	set +x
        #peer chaincode install $CCPACKAGE
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done

#    echo "*******************instantiate chaincode only need one org*********************"
#    for ch in ${NODES[*]}; do
#        setGlobals $ch
#        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
#            peer chaincode instantiate -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
#        else
#           peer chaincode instantiate -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
#        fi
#        echo "===================== PEER$ch instantiate ===================== "
#    done
#    echo "***************test is chaincode depoly success!********************"
    #peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
}

3_Upgrade () {
    echo "**********************creat  chaincode package*******************"
    if [ "$CCVERSION" == "" ]; then
        echo "3_Upgrade error eg: ./deployCC.sh 3 1.1"
        exit 1
    fi

	if [ -f "peer" ]; then
            echo "Using Peer -> peer"
	else
	    echo "miss peer"
        exit 1
	fi
    setGlobals 0
    peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

    echo "*********************all peers install chaincode by package method******************"
    for ch in 0; do
        setGlobals $ch
        peer chaincode install $CCPACKAGE
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done
    # from code
#    echo "all peers install chaincode by path method"
#    for ch in ${NODES[*]}; do
#        setGlobals $ch
#        peer chaincode install -n $CCNAME -v $CCVERSION -p $CCPATH
#        echo "===================== PEER$ch install ===================== "
#        sleep 2
#        echo
#    done

#    echo "*********************upgrade chaincode ******************"
#    for ch in ${NODES[*]}; do
#        setGlobals $ch
#        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
#            peer chaincode upgrade -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
#        else
#           peer chaincode upgrade -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
#        fi
#    done
#    echo "test is chaincode depoly success!"
}

4_Test () {
  echo "************************Test Query******************"
  setGlobals 0
  #  peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
  set -x
  peer chaincode query -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS2 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
  peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS1 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
  set +x
  #peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS2 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

5_MakePackage () {
    echo "************************creat  chaincode package******************"
    rm -rf $CCPACKAGE
    setGlobals 0
    #peer chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE
  set -x
    peer lifecycle chaincode package $CCPACKAGE --path $CCPATH --lang golang --label $CCLABEL
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

8_getinstalledpackage () {
  setGlobals 0
  set -x
  peer lifecycle chaincode queryinstalled
  if [ "$INITREQUIRED" = "true" ]; then
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  -C $CHANNEL_NAME --init-required --sequence 1 --tls true --cafile $ORDERER_CA --output json
  else
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  -C $CHANNEL_NAME --version $CCVERSION --sequence 1 --signature-policy "$POLICY" --tls true --cafile $ORDERER_CA --output json
  fi
  set +x
}

9_approveformyorg () {
  for ch in ${NODES[*]}; do
    setGlobals $ch
       #peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA 
       #peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --channel-config-policy Channel/Application/Writers 
    set -x
    if [ "$INITREQUIRED" = "true" ]; then
      peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --signature-policy "$POLICY" 
    else
      peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --signature-policy "$POLICY" 
    fi
      # peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA 
       #peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --init-required --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')" 
       #peer lifecycle chaincode approveformyorg -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --init-required 
       #peer lifecycle chaincode approveformyorg -o $ORDERADDRESS --channelID $CHANNEL_NAME --name $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --init-required --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')" 
       #peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name $CCNAME --version $CCVERSION --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA --init-required --signature-policy $POLICY 
    done
  sleep 2
  if [ "$INITREQUIRED" = "true" ]; then
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  -C $CHANNEL_NAME --init-required --sequence 1 --tls true --cafile $ORDERER_CA --output json
  else
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  -C $CHANNEL_NAME --version $CCVERSION --sequence 1 --tls true --cafile $ORDERER_CA --output json
  fi
  set +x
}

10_commit () { 
  setGlobals 0
  set -x
  if [ "$INITREQUIRED" = "true" ]; then
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME -v $CCVERSION  -C $CHANNEL_NAME --init-required --sequence 1 --tls true --cafile $ORDERER_CA --output json
    peer lifecycle chaincode commit -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --sequence 1 --init-required --tls --signature-policy "$POLICY" --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT
  else       
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  -C $CHANNEL_NAME --version $CCVERSION --sequence 1 --tls true --cafile $ORDERER_CA --output json
    peer lifecycle chaincode commit -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --sequence 1  --tls --signature-policy "$POLICY" --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT
  fi
  set +x
    #peer lifecycle chaincode commit -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --sequence 1 --init-required --tls true --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE 
    #peer lifecycle chaincode commit -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --sequence 1 --init-required --tls true --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT
    #peer lifecycle chaincode commit -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT
   #peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $INITARGS --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT 
   #peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $INITARGS --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA 
}

11_instantiate () {
    setGlobals 0
    peer chaincode invoke -o $ORDERADDRESS --isInit -C $CHANNEL_NAME -n $CCNAME -c $INITARGS --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT --waitForEvent 
}

12_checkcommitreadiness () {
    setGlobals 0
    #peer lifecycle chaincode querycommitted -o $ORDERADDRESS --channelID $CHANNEL_NAME -n $CCNAME --version $CCVERSION --init-required --sequence 1 --tls --cafile $ORDERER_CA --output json
    #peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME -n $CCNAME -v $CCVERSION --init-required --sequence 1 --tls true --cafile $ORDERER_CA --output json
    peer lifecycle chaincode checkcommitreadiness -o $ORDERADDRESS -n $CCNAME  --init-required --sequence 1 --tls true --cafile $ORDERER_CA --output json
}

13_test () {
   setGlobals 0
   peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS1 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT
   peer chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS2 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --peerAddresses $ORG1_PEER0 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2TLSROOT

}

9_querycommitted () {
  setGlobals 0
  peer lifecycle chaincode querycommitted

}

echo "#################################################################"
echo "#######    TLS is $CORE_PEER_TLS_ENABLED   ##########"
echo "#################################################################"
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
    8_getinstalledpackage
elif [ $1 -eq 9 ]; then
    9_approveformyorg 
elif [ $1 -eq 10 ]; then
    10_commit
elif [ $1 -eq 11 ]; then
    11_instantiate
elif [ $1 -eq 12 ]; then
    12_checkcommitreadiness
elif [ $1 -eq 13 ]; then
    13_test
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


