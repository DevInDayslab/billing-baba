import type { InvitationDetails } from '../api/invitations';
import { roleLabel } from '../api/invitations';

type InvitationCardProps = {
  invitation: InvitationDetails;
  onAccept: () => void;
  onReject: () => void;
  isAccepting: boolean;
  isRejecting: boolean;
};

function formatExpiry(iso: string): string {
  return new Date(iso).toLocaleString(undefined, {
    dateStyle: 'medium',
    timeStyle: 'short',
  });
}

export function InvitationCard({
  invitation,
  onAccept,
  onReject,
  isAccepting,
  isRejecting,
}: InvitationCardProps) {
  const busy = isAccepting || isRejecting;

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
      <p className="text-sm font-medium uppercase tracking-wide text-slate-500">
        You&apos;re invited to join
      </p>
      <h1 className="mt-2 text-3xl font-bold text-slate-900">
        {invitation.company_name}
      </h1>

      <dl className="mt-8 space-y-4">
        <div>
          <dt className="text-xs font-medium uppercase tracking-wide text-slate-500">
            Owner
          </dt>
          <dd className="mt-1 text-base text-slate-900">
            {invitation.owner_name}
            <span className="block text-sm text-slate-600">
              {invitation.owner_phone}
            </span>
          </dd>
        </div>
        <div>
          <dt className="text-xs font-medium uppercase tracking-wide text-slate-500">
            Role
          </dt>
          <dd className="mt-1 text-base font-medium text-slate-900">
            {roleLabel(invitation.role)}
          </dd>
        </div>
        <div>
          <dt className="text-xs font-medium uppercase tracking-wide text-slate-500">
            Expires
          </dt>
          <dd className="mt-1 text-base text-slate-900">
            {formatExpiry(invitation.expires_at)}
          </dd>
        </div>
      </dl>

      <div className="mt-8 flex flex-col gap-3 sm:flex-row">
        <button
          type="button"
          onClick={onAccept}
          disabled={busy}
          className="flex-1 rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isAccepting ? 'Accepting…' : 'Accept invitation'}
        </button>
        <button
          type="button"
          onClick={onReject}
          disabled={busy}
          className="flex-1 rounded-xl border border-slate-300 px-4 py-3 text-sm font-semibold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isRejecting ? 'Rejecting…' : 'Reject'}
        </button>
      </div>
    </div>
  );
}
