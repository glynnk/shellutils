source <(kubectl completion bash)


function kube-nodes() {
  echo | awk '{printf "%-2s %-50s %-15s %s\n", "--", "Node", "Type", "Ready"}'
  kubectl get nodes -o json | \
	  jq -r '.items[] | "\(.metadata.name) \(.metadata.labels["beta.kubernetes.io/instance-type"]) \(.status.conditions[] | select(.type=="Ready") | .status)"' | \
	  awk '{printf "%-2s %-50s %-15s %s\n", NR, $1, $2, $3}'
}
