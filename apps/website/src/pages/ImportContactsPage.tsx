import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { ApiRequestError } from '../api/client';
import { usePartyContactImportPublic } from '../api/party-contact-import';
import { ErrorState } from '../components/ErrorState';
import { LoadingState } from '../components/LoadingState';
import { DOWNLOAD_URL, tryOpenImportContactsApp } from '../services/deep-link';

export function ImportContactsPage() {
  const { token } = useParams<{ token: string }>();
  const query = usePartyContactImportPublic(token);

  useEffect(() => {
    if (token) {
      tryOpenImportContactsApp(token);
    }
  }, [token]);

  if (query.isLoading) {
    return <LoadingState />;
  }

  if (query.error) {
    const error = query.error;
    if (error instanceof ApiRequestError) {
      if (error.status === 404) {
        return (
          <ErrorState
            title="Link not found"
            description="This import link is invalid or has been removed."
          />
        );
      }
      if (error.status === 410) {
        return (
          <ErrorState
            title="Link expired"
            description="Start a new import from the Billing Baba desktop app."
          />
        );
      }
    }
    return (
      <ErrorState
        title="Unable to open import"
        description="Please try again from the desktop app."
      />
    );
  }

  const data = query.data;
  if (!data) {
    return <LoadingState />;
  }

  if (data.status === 'expired' || data.status === 'cancelled') {
    return (
      <ErrorState
        title="Link expired"
        description="Start a new import from the Billing Baba desktop app."
      />
    );
  }

  return (
    <main style={{ maxWidth: 480, margin: '48px auto', padding: 24 }}>
      <h1 style={{ fontSize: 24, marginBottom: 8 }}>Import contacts</h1>
      <p style={{ color: '#555', marginBottom: 24 }}>
        Import phone contacts as parties for <strong>{data.company_name}</strong>.
      </p>
      <p style={{ marginBottom: 16 }}>
        We&apos;re opening the Billing Baba app. If nothing happens, tap below.
      </p>
      <button
        type="button"
        onClick={() => token && tryOpenImportContactsApp(token)}
        style={{
          padding: '12px 20px',
          fontSize: 16,
          cursor: 'pointer',
          marginBottom: 16,
        }}
      >
        Open in Billing Baba
      </button>
      <p style={{ fontSize: 14, color: '#666' }}>
        Don&apos;t have the app?{' '}
        <a href={DOWNLOAD_URL}>Download Billing Baba</a>
      </p>
    </main>
  );
}
