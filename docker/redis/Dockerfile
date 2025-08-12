FROM redis:7.2-alpine

# Optional: copy seeding script and CSV into the image
COPY seed-quotes.sh /docker-entrypoint-initdb.d/seed-quotes.sh
COPY quotes.csv /docker-entrypoint-initdb.d/quotes.csv

# Optional but helpful
EXPOSE 6379