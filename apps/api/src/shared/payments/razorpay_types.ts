export type RazorpayOrderResult = {
  id: string;
  amount: number;
  currency: string;
};

export type RazorpayPaymentResult = {
  id: string;
  orderId: string;
  amount: number;
  currency: string;
  status: string;
  method: string | null;
  captured: boolean;
};

export type RazorpayCreateOrderInput = {
  amountPaise: number;
  currency: string;
  receipt: string;
  notes?: Record<string, string>;
};

export type GatewayWebhookPayload = {
  event?: string;
  payload?: {
    payment?: {
      entity?: {
        id?: string;
        order_id?: string;
        status?: string;
        method?: string;
      };
    };
    order?: { entity?: { id?: string } };
    refund?: { entity?: { payment_id?: string; id?: string } };
  };
};
