import { Link } from 'react-router-dom';
import { DOWNLOAD_URL } from '../../services/deep-link';

export function DownloadPage() {
  return (
    <section className="four" style={{ minHeight: '50vh', padding: '4rem 1rem' }}>
      <h1>
        Get started in less than <span>60 seconds</span>
      </h1>
      <p style={{ color: 'white', textAlign: 'center', maxWidth: '40rem' }}>
        Download Billing Baba for desktop and mobile. Manage billing, inventory, and GST from
        anywhere.
      </p>
      <div className="btn">
        <a href={DOWNLOAD_URL} target="_blank" rel="noreferrer">
          <img src="/assets/landing/get_it_on_google_play.png" alt="Get it on Google Play" />
        </a>
        <a href={DOWNLOAD_URL}>
          <button type="button">Download Billing Baba</button>
        </a>
      </div>
      <p style={{ color: 'white', marginTop: '1rem' }}>
        Need help? <Link to="/contact" style={{ color: '#ffe500' }}>Contact us</Link>
      </p>
    </section>
  );
}
