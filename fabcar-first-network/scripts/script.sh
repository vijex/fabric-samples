#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
1

#!/bin/bash

2

​

3

echo

4

echo " ____    _____      _      ____    _____ "

5

echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"

6

echo "\___ \    | |     / _ \   | |_) |   | |  "

7

echo " ___) |   | |    / ___ \  |  _ <    | |  "

8

echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "

9

echo

10

echo "Build your first network (BYFN) end-to-end test"

11

echo

12

CHANNEL_NAME="$1"

13

DELAY="$2"

14

LANGUAGE="$3"

15

TIMEOUT="$4"

16

VERBOSE="$5"

17

: ${CHANNEL_NAME:="mychannel"}

18

: ${DELAY:="3"}

19

: ${LANGUAGE:="golang"}

20

: ${TIMEOUT:="10"}

21

: ${VERBOSE:="false"}

22

LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`

23

COUNTER=1

24

MAX_RETRY=5

25

​

26

CC_SRC_PATH="github.com/chaincode/fabcar/go/"

27

if [ "$LANGUAGE" = "node" ]; then

28

        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/fabcar/node/"


97

​

98

22

99

​

100

LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`

101

​

102

23

103

​

104

COUNTER=1

105

​

106

24

107

​

108

MAX_RETRY=5

109

​

110

25

111

​

112

•

113

​

114

26

115

​

116

CC_SRC_PATH="github.com/chaincode/fabcar/go/"

117

​

118

27

119

​

120

if [ "$LANGUAGE" = "node" ]; then

121

​

122

28

123

​

124

        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/fabcar/node/"

125

​

126

29

127

​

128

fi

129

​

130

30

131

​

132

•

133

​

134

31

135

​

136

echo "Channel name : "$CHANNEL_NAME

137

​

138

32

139

​

140

•

141

​

142

33

143

​

144

# import utils

145

​

146

34

147

​

148

. scripts/utils.sh

149

​

150

35

151

​

152

•

153

​

154

36

155

​

156

createChannel() {
29

fi

30

​

31

echo "Channel name : "$CHANNEL_NAME

32

​

33

# import utils

34

. scripts/utils.sh

35

​

36

createChannel() {

37

        setGlobals 0 1

38

​

39

        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then

40

                set -x

41

                peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt

42

                res=$?

43

                set +x

44

        else

45

                                set -x

46

                peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt

47

                res=$?

48

                                set +x

49

        fi
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5

CC_SRC_PATH="github.com/chaincode/fabcar/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/fabcar/node/"
fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	for org in 1 2; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2

## Install chaincode on peer0.org1 and peer0.org2
echo "Installing chaincode on peer0.org1..."
installChaincode 0 1
echo "Install chaincode on peer0.org2..."
installChaincode 0 2

# Instantiate chaincode on peer0.org2
echo "Instantiating chaincode on peer0.org2..."
instantiateChaincode 0 2

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1..."
chaincodeQuery 0 1 

# Invoke chaincode on peer0.org1 and peer0.org2
echo "Sending invoke transaction on peer0.org1 peer0.org2..."
chaincodeInvoke 0 1 0 2

## Install chaincode on peer1.org2
echo "Installing chaincode on peer1.org2..."
installChaincode 1 2

# Query on chaincode on peer1.org2, check if the result is 90
echo "Querying chaincode on peer1.org2..."
chaincodeQuery 1 2 


echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
