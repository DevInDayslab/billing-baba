export function ContactPage() {
  return (
    <section className="five" style={{ minHeight: '60vh' }}>
      <h1>
        <div className="circle"></div>
        Contact Us
      </h1>
      <div className="sec" style={{ alignItems: 'flex-start', gap: '2rem' }}>
        <img src="/assets/landing/landing_Tile_4.png" alt="" />
        <div className="qna" style={{ padding: '2rem' }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 600, marginBottom: '1rem' }}>
            Get in touch
          </h2>
          <p style={{ marginBottom: '0.75rem' }}>
            Email:{' '}
            <a href="mailto:support@billingbaba.com" style={{ color: '#0090d3' }}>
              support@billingbaba.com
            </a>
          </p>
          <p style={{ marginBottom: '0.75rem' }}>
            Address: Design Agency Head Office. Airport Road United Arab Emirate
          </p>
          <p>We typically respond within one business day.</p>
        </div>
      </div>
    </section>
  );
}
