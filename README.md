# Shards of the Grid (Team 10)
See [the wiki](https://github.com/uiowahjmjohnsonselt2024/projectdirectory-selt_2024_team_010/wiki) for more information.

# Project Setup

## Requirements

Make sure you have the following versions installed:

- **Ruby**: 2.6.10
- **Bundler**: 1.17.3

If you need to install a specific version of Bundler, you can run:

```bash
gem install bundler -v 1.17.3
```

## Setup
```bash
bundle install
```
```bash
rake db:setup
```

You will also need to install Redis for job handling:
- **Redis**: 7.4.6

## Install
```bash
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

## Setup
```bash
bundle exec sidekiq
```
