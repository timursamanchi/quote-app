FROM ruby:3.2-alpine AS jekyll-builder

WORKDIR /site

# Install system dependencies
RUN apk add --no-cache build-base gcc libffi-dev yaml-dev

# Avoid native extension gems
RUN bundle config set --local force_ruby_platform true

COPY Gemfile* ./
RUN bundle install

COPY . .
RUN JEKYLL_ENV=production bundle exec jekyll build -d /output

FROM nginx:alpine
COPY --from=jekyll-builder /output /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


