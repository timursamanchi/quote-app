import os
import csv
from flask import Flask, jsonify
import redis
import random

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "quote-redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

def seed_from_csv():
    if not r.keys("quote:*"):
        with open("quotes.csv", newline='', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            for row in reader:
                quote, author = row
                r.set(f"quote:{quote}", f"{quote} — {author}")

@app.route("/quote")
def get_quote():
    keys = r.keys("quote:*")
    if not keys:
        return jsonify({"quote": "No quotes found in Redis"})
    quote = r.get(random.choice(keys))
    return jsonify({"quote": quote})

if __name__ == "__main__":
    seed_from_csv()
    app.run(host="0.0.0.0", port=8080)