{$IFDEF debug}
  {$A-,C FIXED PRELOAD DISCARDABLE,B-,D+,F+,G+,I+,L+,N+,P+,Q+,R+,S+,V+,X+,Y+}
{$ELSE}
  {$A-,C FIXED PRELOAD DISCARDABLE,B-,D-,F+,G+,I-,L-,N+,P+,Q-,R-,S-,V+,X+,Y-}
{$ENDIF}