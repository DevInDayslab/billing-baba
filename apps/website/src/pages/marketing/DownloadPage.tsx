import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { DownloadButton } from '../../components/marketing/DownloadButton';

const PAGE_TITLE = 'Download Billing Baba for Windows';
const PAGE_DESCRIPTION =
  'Download the latest Billing Baba Windows desktop app. Offline-first billing, inventory, and GST for Indian retail.';

export function DownloadPage() {
  useEffect(() => {
    document.title = PAGE_TITLE;
    let meta = document.querySelector('meta[name="description"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.setAttribute('name', 'description');
      document.head.appendChild(meta);
    }
    meta.setAttribute('content', PAGE_DESCRIPTION);
  }, []);

  return (
    <section className="four" style={{ minHeight: '50vh', padding: '4rem 1rem' }}>
      <h1>
        Download for <span>Windows</span>
      </h1>
      <p style={{ color: 'white', textAlign: 'center', maxWidth: '40rem' }}>
        Get the latest desktop build. Manage billing, inventory, and GST with an
        offline-first app built for Indian retail.
      </p>
      <DownloadButton />
      <p style={{ color: 'white', marginTop: '1.5rem' }}>
        Need help? <Link to="/contact" style={{ color: '#ffe500' }}>Contact us</Link>
      </p>
    </section>
  );
}
