INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.clusterIP}')

# Deploy temporary test pod
kubectl run curl-test --image=curlimages/curl:latest --restart=Never -- sleep 120
kubectl wait --for=condition=ready pod curl-test --timeout=30s

# Send 100 requests and count version distribution
kubectl exec curl-test -- sh -c "
for i in \$(seq 1 100); do
  curl -s -H 'Host: app.stable.example.com' -I http://$INGRESS_IP:80/sms/ | grep 'x-app-version:'
done" | awk '{print $2}' | sort | uniq -c

# Cleanup
kubectl delete pod curl-test