/** Named request-body examples for Swagger UI. */

export const authExamples = {
  login: {
    login: {
      summary: 'Login with MSG91 token',
      value: {
        access_token: 'msg91_widget_access_token_here',
        phone: '9876543210',
      },
    },
  },
  refresh: {
    refresh: {
      summary: 'Refresh session',
      value: {
        refresh_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        business_id: '550e8400-e29b-41d4-a716-446655440000',
      },
    },
  },
  logout: {
    logout: {
      summary: 'Logout',
      value: { refresh_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
    },
  },
};

export const businessExamples = {
  createBusiness: {
    retailShop: {
      summary: 'Create retail shop',
      value: {
        name: 'Sharma General Store',
        owner_name: 'Raj Sharma',
        phone: '9876543210',
        gstin: '27AABCU9603R1ZM',
        business_type: 'retail',
        state: 'Maharashtra',
        state_code: '27',
        currency: 'INR',
        address: '123 MG Road, Pune',
      },
    },
  },
  updateProfile: {
    updateGst: {
      summary: 'Update GST details',
      value: {
        name: 'Sharma General Store',
        phone: '9876543210',
        gstin: '27AABCU9603R1ZM',
        business_type: 'retail',
        state: 'Maharashtra',
        pincode: '411001',
        address: '123 MG Road, Pune',
      },
    },
  },
};

export const partyExamples = {
  createCustomer: {
    customer: {
      summary: 'Create customer',
      value: {
        name: 'Amit Patel',
        mobile: '9876543210',
        email: 'amit@example.com',
        party_type: 'customer',
        party_category: 'retailer',
        pricing_tier: 'tier_1',
        state_code: '27',
        state: 'Maharashtra',
        opening_balance: '0',
        is_active: true,
      },
    },
  },
  createSupplier: {
    supplier: {
      summary: 'Create supplier',
      value: {
        name: 'ABC Distributors Pvt Ltd',
        mobile: '9123456789',
        gstin: '27AABCU9603R1ZM',
        party_type: 'supplier',
        party_category: 'wholesaler',
        pricing_tier: 'tier_2',
        state_code: '27',
        state: 'Maharashtra',
        credit_limit: '50000',
        opening_balance: '10000',
        is_active: true,
      },
    },
  },
};

export const salesExamples = {
  createTaxInvoice: {
    taxInvoice: {
      summary: 'Create tax invoice (draft)',
      value: {
        document_type: 'tax_invoice',
        document_series: 'INV',
        party_id: '550e8400-e29b-41d4-a716-446655440001',
        is_gst_formal: true,
        party_state_code: '27',
        notes: 'Payment due in 15 days',
      },
    },
  },
  createEstimate: {
    estimate: {
      summary: 'Create estimate',
      value: {
        document_type: 'estimate',
        document_series: 'EST',
        party_id: '550e8400-e29b-41d4-a716-446655440001',
        is_gst_formal: false,
      },
    },
  },
  addLine: {
    productLine: {
      summary: 'Add product line',
      value: {
        item_id: '550e8400-e29b-41d4-a716-446655440002',
        quantity: '10',
        unit: 'PCS',
        unit_price: '150.00',
        discount_amount: '0',
        tax_type: 'cgst_sgst',
        tax_rate: '18',
      },
    },
  },
  finalize: {
    finalize: {
      summary: 'Finalize with godown',
      value: { godown_id: '550e8400-e29b-41d4-a716-446655440003' },
    },
  },
  convert: {
    toInvoice: {
      summary: 'Convert estimate to tax invoice',
      value: { target_type: 'tax_invoice', apply_gst: true },
    },
  },
};

export const purchaseExamples = {
  createPurchaseBill: {
    purchaseBill: {
      summary: 'Create purchase bill (draft)',
      value: {
        document_type: 'purchase_bill',
        document_series: 'PB',
        party_id: '550e8400-e29b-41d4-a716-446655440001',
        is_gst_formal: true,
        supplier_invoice_number: 'SUP-2024-001',
        due_date: '2024-04-15',
      },
    },
  },
  addLine: {
    productLine: {
      summary: 'Add purchase line',
      value: {
        item_id: '550e8400-e29b-41d4-a716-446655440002',
        quantity: '100',
        unit: 'PCS',
        unit_price: '80.00',
        tax_type: 'cgst_sgst',
        tax_rate: '12',
        tax_inclusive: false,
      },
    },
  },
};

export const paymentExamples = {
  receivePayment: {
    received: {
      summary: 'Receive payment from customer',
      value: {
        party_id: '550e8400-e29b-41d4-a716-446655440001',
        direction: 'received',
        amount: '5000.00',
        payment_mode: 'upi',
        reference_number: 'UPI123456',
        allocations: [
          {
            sales_document_id: '550e8400-e29b-41d4-a716-446655440010',
            allocated_amount: '5000.00',
          },
        ],
      },
    },
  },
  makePayment: {
    paid: {
      summary: 'Pay supplier',
      value: {
        party_id: '550e8400-e29b-41d4-a716-446655440002',
        direction: 'paid',
        amount: '10000.00',
        payment_mode: 'bank_transfer',
        reference_number: 'NEFT789012',
        allocations: [
          {
            purchase_document_id: '550e8400-e29b-41d4-a716-446655440011',
            allocated_amount: '10000.00',
          },
        ],
      },
    },
  },
};

export const expenseExamples = {
  createExpense: {
    officeRent: {
      summary: 'Record office rent expense',
      value: {
        category_id: '550e8400-e29b-41d4-a716-446655440020',
        amount: '25000.00',
        tax_amount: '0',
        description: 'Office rent — April 2024',
        expense_date: '2024-04-01',
        payment_mode: 'bank_transfer',
      },
    },
  },
};

export const inventoryExamples = {
  createItem: {
    product: {
      summary: 'Create product',
      value: {
        name: 'Premium Basmati Rice 1kg',
        item_type: 'product',
        sku: 'RICE-001',
        hsn_code: '10063010',
        sale_price: '120.00',
        purchase_price: '90.00',
        unit: 'PCS',
        track_stock: true,
        is_active: true,
      },
    },
  },
  createMovement: {
    stockIn: {
      summary: 'Stock in (opening)',
      value: {
        item_id: '550e8400-e29b-41d4-a716-446655440002',
        godown_id: '550e8400-e29b-41d4-a716-446655440003',
        movement_type: 'opening',
        quantity: '100',
        unit: 'PCS',
      },
    },
  },
};

export const jobWorkExamples = {
  createOrder: {
    order: {
      summary: 'Create job work order',
      value: {
        party_id: '550e8400-e29b-41d4-a716-446655440001',
        finished_good_name: 'Custom Steel Frame',
        finished_good_quantity: '50',
        finished_good_unit: 'PCS',
        raw_materials: [
          {
            item_id: '550e8400-e29b-41d4-a716-446655440002',
            quantity: '200',
            unit: 'KG',
            purchase_price: '45.00',
          },
        ],
        additional_costs: [{ label: 'Labour', amount: '5000.00' }],
      },
    },
  },
};

/** Response examples for common scenarios. */
export const responseExamples = {
  health: {
    status: 'ok',
    name: 'Billing Baba API',
    version: '1.0.0',
    environment: 'development',
    uptime: 3600,
    timestamp: '2024-04-01T10:00:00.000Z',
  },
  authSession: {
    access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    refresh_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    expires_in: 3600,
    user: {
      id: '550e8400-e29b-41d4-a716-446655440000',
      phone: '9876543210',
    },
    businesses: [
      {
        id: '550e8400-e29b-41d4-a716-446655440001',
        name: 'Sharma General Store',
        role: 'owner',
      },
    ],
  },
  party: {
    id: '550e8400-e29b-41d4-a716-446655440001',
    name: 'Amit Patel',
    party_type: 'customer',
    mobile: '9876543210',
    is_active: true,
    created_at: '2024-04-01T10:00:00.000Z',
    updated_at: '2024-04-01T10:00:00.000Z',
  },
  category: {
    id: '550e8400-e29b-41d4-a716-446655440001',
    name: 'Groceries',
    item_count: 42,
    created_at: '2024-04-01T10:00:00.000Z',
    updated_at: '2024-04-01T10:00:00.000Z',
  },
};
