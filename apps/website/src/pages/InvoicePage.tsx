import { useParams } from 'react-router-dom';
import { ApiRequestError } from '../api/client';
import { usePublicInvoice } from '../api/invoices';
import { ErrorState } from '../components/ErrorState';
import { InvoiceView } from '../components/InvoiceView';
import { LoadingState } from '../components/LoadingState';

export function InvoicePage() {
  const { token } = useParams<{ token: string }>();
  const invoiceQuery = usePublicInvoice(token);

  if (invoiceQuery.isLoading) {
    return <LoadingState />;
  }

  if (invoiceQuery.error) {
    const error = invoiceQuery.error;
    if (error instanceof ApiRequestError) {
      if (error.status === 404) {
        return (
          <ErrorState
            title="Invoice not found"
            description="This invoice link is invalid or has been removed."
          />
        );
      }
      if (error.status === 410 || error.code === 'INVOICE_SHARE_EXPIRED') {
        return (
          <ErrorState
            title="Link expired"
            description="This invoice link has expired. Ask the business to share a new one."
          />
        );
      }
    }

    return (
      <ErrorState
        title="Something went wrong"
        description="We couldn't load this invoice. Please try again later."
      />
    );
  }

  if (!invoiceQuery.data) {
    return <LoadingState />;
  }

  return <InvoiceView invoice={invoiceQuery.data} />;
}
