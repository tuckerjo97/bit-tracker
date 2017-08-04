import krakenex
import bitstamp.client
import gdax

kraken_client = krakenex.API()
bitstamp_client = bitstamp.client.Public()
gdax_client = gdax.PublicClient()

# Makes 1 call. Complicated limit, refer too : https://www.kraken.com/help/api
def get_kraken_price():
    ticker_call = kraken_client.query_public('Ticker', {'pair': ('XBTUSD, XBTEUR, XBTCAD, XBTGBP, XBTJPY')})

    usd = ticker_call['result']['XXBTZUSD']
    usd_ask = usd['a'][0]
    usd_bid = usd['b'][0]
    usd_last = usd['c'][0]

    eur = ticker_call['result']['XXBTZEUR']
    eur_ask = eur['a'][0]
    eur_bid = eur['b'][0]
    eur_last = eur['c'][0]

    cad = ticker_call['result']['XXBTZCAD']
    cad_ask = cad['a'][0]
    cad_bid = cad['b'][0]
    cad_last = cad['c'][0]

    gbp = ticker_call['result']['XXBTZGBP']
    gbp_ask = gbp['a'][0]
    gbp_bid = gbp['b'][0]
    gbp_last = gbp['c'][0]

    jpy = ticker_call['result']['XXBTZJPY']
    jpy_ask = jpy['a'][0]
    jpy_bid = jpy['b'][0]
    jpy_last = jpy['c'][0]

    print("%s %s %s,%s %s %s,%s %s %s,%s %s %s,%s %s %s" % (usd_ask, usd_bid, usd_last, eur_ask, eur_bid, eur_last,
                                                            cad_ask, cad_bid, cad_last, gbp_ask, gbp_bid, gbp_last,
                                                            jpy_ask, jpy_bid, jpy_last))

# Makes 2 calls. Max's out at 600 requests per 10 minutes before IP ban
def get_bitstamp_price():
    usd = bitstamp_client.ticker()
    usd_ask = usd['ask']
    usd_bid = usd['bid']
    usd_last = usd['last']

    eur = bitstamp_client.ticker(quote = "eur")
    eur_ask = eur['ask']
    eur_bid = eur['bid']
    eur_last = eur['last']

    print("%s %s %s,%s %s %s" % (usd_ask, usd_bid, usd_last, eur_ask, eur_bid, eur_last))

# Makes 2 calls. GDAX max's out at 3 requests per second, or 6 per second bursts
def get_gdax_price():
    usd = gdax_client.get_product_ticker(product_id='BTC-USD')
    usd_ask = usd['ask']
    usd_bid = usd['bid']
    usd_last = usd['price']

    eur = gdax_client.get_product_ticker(product_id='BTC-EUR')
    eur_ask = eur['ask']
    eur_bid = eur['bid']
    eur_last = eur['price']

    print("%s %s %s,%s %s %s" % (usd_ask, usd_bid, usd_last, eur_ask, eur_bid, eur_last))

