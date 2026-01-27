INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.clusterIP}')

# Create test pod
kubectl run rate-limit-test --image=curlimages/curl:latest --restart=Never -- sleep 300
kubectl wait --for=condition=ready pod rate-limit-test --timeout=30s

echo "For user1"
kubectl exec rate-limit-test -- sh -c "
for i in \$(seq 1 15);
  do curl -s -I http://$INGRESS_IP:80/sms/ -H 'Host: app.stable.example.com' -H 'x-user-id: user1' | grep HTTP/1.1;
done" | awk '{$1=""; print $0}' | sort | uniq -c

echo "For user2"
kubectl exec rate-limit-test -- sh -c "
for i in \$(seq 1 15);
  do curl -s -I http://$INGRESS_IP:80/sms/ -H 'Host: app.stable.example.com' -H 'x-user-id: user2' | grep HTTP/1.1;
done" | awk '{$1=""; print $0}' | sort | uniq -c

# Cleanup
kubectl delete pod rate-limit-test