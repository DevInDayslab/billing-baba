import { z } from 'zod';

export const verifyGstinBodySchema = z.object({
  gstin: z.string().min(1, 'GSTIN is required'),
});

export type VerifyGstinBody = z.infer<typeof verifyGstinBodySchema>;

export type GstinVerificationDataDto = {
  gstin: string;
  legal_name: string;
  trade_name: string;
  status: string;
  constitution: string;
  taxpayer_type: string;
  registration_date: string;
  state: string;
  pan: string;
  address: string;
  nature_of_business: string[];
};

export type GstinVerificationResponseDto = {
  success: boolean;
  cached: boolean;
  credits_remaining: number;
  data: GstinVerificationDataDto;
};
