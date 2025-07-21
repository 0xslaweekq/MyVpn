## Installing to machine

```BASH
curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/vpn-install.sh | sudo bash
```

## nginx-ui-no-auth

```BASH
docker pull slaweekq/nginx-ui-no-auth:latest && \
  docker run -d --tty \
  --restart=always \
  --name nginxui \
  -v /etc/nginx:/etc/nginx \
  -p 9001:9001 \
  slaweekq/nginx-ui-no-auth:latest
```


## 💗 Donation

If you find this project useful and would like to support its development, you can make a donation.

### TON

```
UQDqd8rfkOq_TTUBzyMalvJhHeP4hPezjkSyA92mb24VK4Oh
```
