# Codescene install on Istio
This gateway and virtual service will set the access to your codescene service in an Istio 1.0.3 or 1.0.4 environment.

You will need to set or change the host in both GW and VS to your URL.

If you don't have a URL only for codescene (e.g. codescene.my-company.com), you'll need to create a match
```
  - match:
      uri:
        prefix: /
    route:
    - destination:
        port:
          number: 3003
``` 

For SSL terminations at the ingress controller, you may need to include a redirection definition
```
    tls:
      httpsRedirect: true # sends 301 redirect for http requests
```