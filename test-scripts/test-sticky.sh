INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.clusterIP}')

# Create test pod
kubectl run sticky-test --image=curlimages/curl:latest --restart=Never -- sleep 300
kubectl wait --for=condition=ready pod sticky-test --timeout=30s

# Test: All requests should return same version
kubectl exec sticky-test -- sh -c "
curl -s -I -c cookie.txt http://$INGRESS_IP:80/sms/ -H 'Host: app.stable.example.com' | grep 'x-app-version:'
for i in \$(seq 1 20); do
  curl -s -I -b cookie.txt http://$INGRESS_IP:80/sms/ -H 'Host: app.stable.example.com' | grep 'x-app-version:';
done" | awk '{print $2}' | sort | uniq -c

# Cleanup
kubectl delete pod sticky-test