import { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ApiRequestError } from '../api/client';
import {
  useAcceptInvitation,
  useInvitation,
  useRejectInvitation,
} from '../api/invitations';
import { ErrorState } from '../components/ErrorState';
import { InvitationCard } from '../components/InvitationCard';
import { LoadingState } from '../components/LoadingState';

export function InvitePage() {
  const { token } = useParams<{ token: string }>();
  const navigate = useNavigate();
  const invitationQuery = useInvitation(token);
  const acceptMutation = useAcceptInvitation(token);
  const rejectMutation = useRejectInvitation(token);

  useEffect(() => {
    if (invitationQuery.data?.status === 'accepted') {
      navigate(`/invite/${token}/accepted`, { replace: true });
    }
    if (invitationQuery.data?.status === 'rejected') {
      navigate(`/invite/${token}/rejected`, { replace: true });
    }
  }, [invitationQuery.data?.status, navigate, token]);

  if (invitationQuery.isLoading) {
    return <LoadingState />;
  }

  if (invitationQuery.error) {
    const error = invitationQuery.error;
    if (error instanceof ApiRequestError) {
      if (error.status === 404) {
        return (
          <ErrorState
            title="Invitation not found"
            description="This invitation link is invalid or has been removed."
          />
        );
      }
      if (error.status === 410 || error.code === 'INVITATION_EXPIRED') {
        return (
          <ErrorState
            title="Invitation expired"
            description="This invitation has expired. Ask the business owner to send a new one."
          />
        );
      }
      if (error.code === 'INVITATION_NOT_ACTIONABLE') {
        return (
          <ErrorState
            title="Invitation unavailable"
            description={error.message}
          />
        );
      }
    }

    return (
      <ErrorState
        title="Something went wrong"
        description="We couldn't load this invitation. Please try again later."
      />
    );
  }

  if (!invitationQuery.data) {
    return <LoadingState />;
  }

  const actionError =
    acceptMutation.error instanceof ApiRequestError
      ? acceptMutation.error
      : rejectMutation.error instanceof ApiRequestError
        ? rejectMutation.error
        : null;

  return (
    <div className="space-y-4">
      {actionError ? (
        <ErrorState
          title="Could not update invitation"
          description={actionError.message}
        />
      ) : null}
      <InvitationCard
        invitation={invitationQuery.data}
        isAccepting={acceptMutation.isPending}
        isRejecting={rejectMutation.isPending}
        onAccept={() => {
          acceptMutation.mutate(undefined, {
            onSuccess: () => navigate(`/invite/${token}/accepted`),
          });
        }}
        onReject={() => {
          rejectMutation.mutate(undefined, {
            onSuccess: () => navigate(`/invite/${token}/rejected`),
          });
        }}
      />
    </div>
  );
}
