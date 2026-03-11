export async function preparePlanPayment(planCode, billingCycle = 'monthly') {
  const resp = await fetch('/AI/api/payments/prepare', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ planCode, billingCycle })
  });
  return resp.json();
}

export async function completePlanPayment(planCode, billingCycle = 'monthly', paymentMethod = 'card', merchantUid = '') {
  const resp = await fetch('/AI/api/payments/complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ planCode, billingCycle, paymentMethod, merchantUid })
  });
  return resp.json();
}

export async function completeCreditPurchase(packageId, paymentMethod = 'card', merchantUid = '') {
  const resp = await fetch('/AI/api/payments/complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ packageId: String(packageId), paymentMethod, merchantUid })
  });
  return resp.json();
}

export async function fetchCurrentSubscription() {
  const resp = await fetch('/AI/api/subscriptions/current');
  return resp.json();
}
