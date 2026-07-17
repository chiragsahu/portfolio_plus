import requests
import json

# Replace with your actual CoinMarketCap API Key
API_KEY = '3c9f48793fba4e5b8f69bbbd8a1e0e10' 
URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map'

headers = {
    'Accepts': 'application/json',
    'X-CMC_PRO_API_KEY': API_KEY,
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

all_symbols = []
start = 1
limit = 100  # CMC allows fetching up to 5000 items per request

print("Fetching data from CoinMarketCap...")

while True:
    params = {
        'start': start,
        'limit': limit,
        'listing_status': 'active' # Retrieves actively traded markets
    }
    
    try:
        response = requests.get(URL, headers=headers, params=params)
        # If the status code is not 200, stop and print the server's response
        if response.status_code != 200:
            print(f"\nHTTP Error {response.status_code} occurred!")
            print(f"Server Response Preview: {response.text[:300]}")
            break

        data = response.json()
        print("data", data.keys())
        
        # Check if the API returned a successful response
        if data['status']['error_code'] != 0:
            print(f"API Error: {data['status']['error_message']}")
            break
            
        crypto_batch = data['data']
        
        # If no data is returned, we have hit the end of the list
        if not crypto_batch:
            break
            
        for coin in crypto_batch:
            # Safely extract contract addresses for multi-platform cross-referencing
            platform_info = coin.get('platform')
            contract_address = platform_info.get('token_address') if platform_info else None
            blockchain = platform_info.get('name') if platform_info else None

            all_symbols.append({
                'cmc_id': coin['id'],
                'symbol': coin['symbol'],
                'name': coin['name'],
                'slug': coin['slug'],
                'blockchain': blockchain,
                'contract_address': contract_address
            })
            
        print(f"Retrieved items {start} to {start + len(crypto_batch) - 1}")
        
        # Move to the next page index
        start += limit
        
    except Exception as e:
        print(f"An error occurred: {e}")
        break

# Save the structured list to a JSON file for your application to ingest
with open('universal_crypto_map.json', 'w') as f:
    json.dump(all_symbols, f, indent=4)

print(f"\nSuccess! Saved {len(all_symbols)} total crypto records to 'universal_crypto_map.json'")
