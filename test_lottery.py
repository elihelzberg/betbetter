import requests
import json

url = "https://www.michiganlottery.com/api"

payload = [
    {
        "operationName": "RetailPrizesRemaining",
        "variables": {
            "id": 636
        },
        "query": """
        query RetailPrizesRemaining($id: Int!) {
            getRetailTopPrizesRemainingForGameDetails(cms_game_igt_id: $id) {
                prize_level
                prize_amount
                prizes_remaining
                starting_amount
                updatedAt
                __typename
            }
        }
        """
    }
]

headers = {
    "Content-Type": "application/json",
    "Accept": "*/*",
    "cms-type": "production",
    "Origin": "https://www.michiganlottery.com",
    "Referer": "https://www.michiganlottery.com/"
}

response = requests.post(
    url,
    headers=headers,
    json=payload
)

print("Status:", response.status_code)
print(json.dumps(response.json(), indent=2))
