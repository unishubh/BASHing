unset base
unset exchangeTo
unset configuredClient
currencyCodes=(AUD BGN BRL CAD CHF CNY CZK DKK
  EUR GBP HKD HRK HUF IDR ILS INR
  JPY KRW MXN MYR NOK NZD PHP PLN
  RON RUB SEK SGD THB TRY USD ZAR)

getConfiguredClient()
  {
    if command -v curl &>/dev/null; then
      configuredClient="curl"
    elif command -v wget &>/dev/null; then
      configuredClient="wget"
    elif command -v http &>/dev/null; then
      configuredClient="httpie"
    elif command -v fetch &>/dev/null; then
      configuredClient="fetch"
    else
      echo "Error: This tool reqires either curl, wget, httpie or fetch to be installed." >&2
      return 1
    fi
  }

   httpGet()
  {
      echo "Http Get"
     # echo $configuredClient
     # echo $@
    case "$configuredClient" in
      curl)  curl -A curl -s "$@" ;;
      wget)  wget -qO- "$@" ;;
      httpie) http -b GET "$@" ;;
      fetch) fetch -q "$@" ;;
    esac
  }

checkValidCurrency()
{
  if [[ "${currencyCodes[*]}" == *"$(echo "${@}" | tr -d '[:space:]')"* ]]; then
    echo "0"
  else
    echo "1"
  fi
}

checkBase()
{
  base=$1

  base=$(echo $base | tr /a-z/ /A-Z/)
  if [[ $(checkValidCurrency $base) == "1" ]]; then
    unset base
    echo "Invalid base currency"
    exit 1
  fi
#   echo "From Fn";
#   echo $base
}

checkExchangeTo()
{
  exchangeTo=$1
  exchangeTo=$(echo $exchangeTo | tr /a-z/ /A-Z/)
  if [[ $(checkValidCurrency $exchangeTo) == "1" ]]; then
    echo "Invalid exchange currency"
    unset exchangeTo
    exit 1
  fi
#   echo "From fn"
#   echo $exchangeTo
}

checkAmount()
{
  amount=$1
  if [[ ! "$amount" =~ ^[0-9]+(\.[0-9]+)?$ ]]
  then
    echo "The amount has to be a number"
    unset amount
    exit 1
  fi
#   echo "From fn"
#   echo $amount
}

checkInternet()
{
    #echo "Internet"
    #httpGet github.com
    httpGet github.com > /dev/null 2>&1 || { echo "Error: no active internet connection" >&2; return 1; } # query github with a get request
}

convertCurrency()
{
  gh=$(httpGet https://api.exchangeratesapi.io/latest?base=$base )
  #echo $gh
  exchangeRate=$(echo $gh |  grep -Eo "$exchangeTo\":[0-9.]*" |  grep -Eo "[0-9.]*")
  #exchangeRate=$(httpGet "https://api.exchangeratesapi.io/latest?base=$base" | grep -Eo "$exchangeTo\":[1-9.]*" | grep -Eo "[0-9.]*") > /dev/null
  #exchangeRate=$gh
  #echo "Exchange rate"
  #echo $exchangeRate
  if ! command -v bc &>/dev/null; then
    oldRate=$exchangeRate
    exchangeRate=$(echo $exchangeRate | grep -Eo "^[0-9]*" )
    amount=$(echo $amount | grep -Eo "^[0-9]*" )
    exchangeAmount=$(( $exchangeRate * $amount ))
    exchangeRate=$oldRate
  else
    exchangeAmount=$( echo "$exchangeRate * $amount" | bc )
  fi

  cat <<EOF
=========================
| $base to $exchangeTo
| Rate: $exchangeRate
| $base: $amount
| $exchangeTo: $exchangeAmount
=========================
EOF
}
getConfiguredClient || exit 1
#echo $1
#echo "Checking Internet"
checkInternet || exit 1
#echo "Checking Base"
checkBase $1
#echo "Checking Exchange"
checkExchangeTo $2
#echo "Checking Amount"
checkAmount $3
convertCurrency
exit 0