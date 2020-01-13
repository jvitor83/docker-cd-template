# Docker Continuous Delivery Template

```sh
npm install -g gomplate
echo '{"SOFTWARE_NAME":"software","DNS_PREFIX":"software-api","DNS_SUFFIX":"enterprise.com"}' > config.json
gomplate --datasource config=config.json --input-dir=docker-cd-template --output-dir=template-result-1
```
