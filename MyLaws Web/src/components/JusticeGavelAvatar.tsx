'use client';

import React, { useEffect, useRef, useState } from 'react';

interface JusticeGavelAvatarProps {
  size?: number;
  className?: string;
}

/**
 * Courtroom Justice Gavel ("Order! Order!") Avatar
 *
 * Faithfully mirrors the native mobile application's OrderOrderGavelAvatar:
 * - High-contrast obsidian circular medallion badge with gold/silver perimeter
 * - Rhythmic double-strike ("Order! Order!") gavel hammer motion onto a judicial sound block
 * - Expanding acoustic shockwave sound ripples emanating on each strike impact
 * - Synchronized expanding radar pulse ring
 */
export function JusticeGavelAvatar({ size = 48, className = '' }: JusticeGavelAvatarProps) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [pulse, setPulse] = useState<{ scale: number; opacity: number }>({ scale: 1, opacity: 0 });

  const badgeSize = size - 6; // inner circular medallion size (e.g. 42px)

  useEffect(() => {
    let animId: number;
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // High DPI scaling for ultra-crisp vector rendering
    const dpr = typeof window !== 'undefined' ? window.devicePixelRatio || 1 : 1;
    canvas.width = badgeSize * dpr;
    canvas.height = badgeSize * dpr;

    const startTime = performance.now();
    const cycleDuration = 1600; // 1.6s full courtroom strike cycle

    // Coordinate scale relative to baseline 40x40 canvas
    const baseWidth = 40.0;
    const s = badgeSize / baseWidth;

    // Anchor coordinates from native app
    const pivot = { x: 26.5 * s, y: 27.0 * s };
    const length = 13.5 * s;
    const baseAngle = -155.0 * (Math.PI / 180.0); // angle at rest
    const impactPoint = { x: 11.8 * s, y: 26.0 * s };

    function easeOutCubic(x: number): number {
      return 1 - Math.pow(1 - x, 3);
    }

    function easeInQuad(x: number): number {
      return x * x;
    }

    function easeOutQuad(x: number): number {
      return 1 - (1 - x) * (1 - x);
    }

    function drawRRect(
      c: CanvasRenderingContext2D,
      x: number,
      y: number,
      w: number,
      h: number,
      r: number
    ) {
      if (c.roundRect) {
        c.beginPath();
        c.roundRect(x, y, w, h, r * s);
        c.fill();
      } else {
        const rad = r * s;
        c.beginPath();
        c.moveTo(x + rad, y);
        c.lineTo(x + w - rad, y);
        c.quadraticCurveTo(x + w, y, x + w, y + rad);
        c.lineTo(x + w, y + h - rad);
        c.quadraticCurveTo(x + w, y + h, x + w - rad, y + h);
        c.lineTo(x + rad, y + h);
        c.quadraticCurveTo(x, y + h, x, y + h - rad);
        c.lineTo(x, y + rad);
        c.quadraticCurveTo(x, y, x + rad, y);
        c.closePath();
        c.fill();
      }
    }

    const render = (now: number) => {
      const elapsed = (now - startTime) % cycleDuration;
      const t = elapsed / cycleDuration;

      // 1. Calculate dynamic strike angle ("Order! Order!" rhythm)
      let angleDeg = 0.0;
      let impact1Progress = -1.0;
      let impact2Progress = -1.0;

      if (t < 0.16) {
        // Wind-up lift: 0 to 30 degrees upward
        const p = t / 0.16;
        angleDeg = 30.0 * easeOutCubic(p);
      } else if (t < 0.25) {
        // Strike 1 ("Order!"): Downward snap
        const p = (t - 0.16) / 0.09;
        angleDeg = 30.0 * (1.0 - easeInQuad(p));
      } else if (t < 0.34) {
        // Bounce after Strike 1: Up to 11 degrees
        const p = (t - 0.25) / 0.09;
        angleDeg = 11.0 * Math.sin(p * Math.PI);
        impact1Progress = (t - 0.25) / 0.13;
      } else if (t < 0.38) {
        impact1Progress = (t - 0.25) / 0.13;
      }

      if (t >= 0.34 && t < 0.43) {
        // Strike 2 ("Order!"): Downward snap
        const p = (t - 0.34) / 0.09;
        angleDeg = 11.0 * (1.0 - easeInQuad(p));
      } else if (t >= 0.43 && t < 0.52) {
        // Settle bounce: Micro bounce up to 3.5 degrees
        const p = (t - 0.43) / 0.09;
        angleDeg = 3.5 * Math.sin(p * Math.PI);
        impact2Progress = (t - 0.43) / 0.13;
      } else if (t >= 0.52 && t < 0.58) {
        impact2Progress = (t - 0.43) / 0.13;
      } else if (t >= 0.58) {
        // Judicial pause
        angleDeg = 0.0;
      }

      // Update radar pulse ring state
      const pulseProg = t < 0.6 ? t / 0.6 : (t - 0.6) / 0.4;
      const pScale = 0.95 + 0.65 * easeOutQuad(pulseProg);
      const pOpacity = (1.0 - easeOutQuad(pulseProg)) * 0.45;
      setPulse({ scale: pScale, opacity: pOpacity });

      // Clear Canvas
      ctx.save();
      ctx.scale(dpr, dpr);
      ctx.clearRect(0, 0, badgeSize, badgeSize);

      // Clip canvas into circular medallion
      ctx.beginPath();
      ctx.arc(badgeSize / 2, badgeSize / 2, badgeSize / 2, 0, Math.PI * 2);
      ctx.clip();

      // Background obsidian gradient
      const bgGrad = ctx.createRadialGradient(
        badgeSize / 2,
        badgeSize / 2,
        2,
        badgeSize / 2,
        badgeSize / 2,
        badgeSize / 2
      );
      bgGrad.addColorStop(0, '#1E232A');
      bgGrad.addColorStop(1, '#0E1115');
      ctx.fillStyle = bgGrad;
      ctx.fillRect(0, 0, badgeSize, badgeSize);

      // 2. Draw Impact Sound Ripples (Acoustic shockwaves)
      const drawRipples = (prog: number, maxRadius: number, initialOpacity: number) => {
        if (prog < 0.0 || prog > 1.0) return;
        const opacity = (1.0 - prog) * initialOpacity;
        const r1 = (3.0 + (maxRadius - 3.0) * prog) * s;
        const r2 = r1 * 0.65;

        ctx.save();
        ctx.strokeStyle = `rgba(255, 255, 255, ${opacity})`;
        ctx.lineWidth = 1.3 * s;
        ctx.lineCap = 'round';

        // Upward expanding acoustic sound arcs
        ctx.beginPath();
        ctx.arc(impactPoint.x, impactPoint.y, r1, -Math.PI * 0.9, -Math.PI * 0.2, false);
        ctx.stroke();

        if (r2 > 2.5 * s) {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(218, 174, 106, ${opacity * 0.85})`;
          ctx.lineWidth = 1.0 * s;
          ctx.arc(impactPoint.x, impactPoint.y, r2, -Math.PI * 0.85, -Math.PI * 0.25, false);
          ctx.stroke();
        }
        ctx.restore();
      };

      if (impact1Progress >= 0.0 && impact1Progress <= 1.0) {
        drawRipples(impact1Progress, 9.5, 0.85);
      }
      if (impact2Progress >= 0.0 && impact2Progress <= 1.0) {
        drawRipples(impact2Progress, 11.5, 0.95);
      }

      // 3. Draw Sounding Block (Base Stand)
      // Base bottom lip
      ctx.fillStyle = '#8A9099';
      drawRRect(
        ctx,
        (13.5 - 17.0 / 2) * s,
        (29.2 - 2.2 / 2) * s,
        17.0 * s,
        2.2 * s,
        0.8
      );

      // Main sound block pedestal
      ctx.fillStyle = '#FFFFFF';
      drawRRect(
        ctx,
        (13.5 - 14.5 / 2) * s,
        (27.2 - 3.2 / 2) * s,
        14.5 * s,
        3.2 * s,
        1.2
      );

      // 4. Draw Courtroom Gavel (Hammer)
      ctx.save();
      ctx.translate(pivot.x, pivot.y);
      ctx.rotate(baseAngle + (angleDeg * Math.PI) / 180.0);

      // A. Gavel Handle
      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 2.1 * s;
      ctx.lineCap = 'round';
      ctx.beginPath();
      ctx.moveTo(1.5 * s, 0);
      ctx.lineTo(length, 0);
      ctx.stroke();

      // B. Pommel / Grip End
      ctx.fillStyle = '#D6D9DE';
      ctx.beginPath();
      ctx.arc(1.0 * s, 0, 1.7 * s, 0, Math.PI * 2);
      ctx.fill();

      // C. Mallet Barrel (Double-ended Hammer Head)
      ctx.fillStyle = '#FFFFFF';
      drawRRect(
        ctx,
        length - (5.2 * s) / 2,
        -(10.2 * s) / 2,
        5.2 * s,
        10.2 * s,
        1.2
      );

      // D. Central decorative dark band
      ctx.strokeStyle = '#1E2228';
      ctx.lineWidth = 1.1 * s;
      ctx.beginPath();
      ctx.moveTo(length - 2.5 * s, 0);
      ctx.lineTo(length + 2.5 * s, 0);
      ctx.stroke();

      // E. Striking face rim caps
      // Top end cap
      ctx.fillStyle = '#DCE0E5';
      drawRRect(
        ctx,
        length - (6.2 * s) / 2,
        (-5.0 - 1.3 / 2) * s,
        6.2 * s,
        1.3 * s,
        0.6
      );

      // Bottom end cap (the striking face hitting the block)
      ctx.fillStyle = '#E8ECF0';
      drawRRect(
        ctx,
        length - (6.2 * s) / 2,
        (5.0 - 1.3 / 2) * s,
        6.2 * s,
        1.3 * s,
        0.6
      );

      ctx.restore();
      ctx.restore();

      animId = requestAnimationFrame(render);
    };

    animId = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(animId);
    };
  }, [badgeSize]);

  return (
    <div
      className={`relative flex items-center justify-center shrink-0 ${className}`}
      style={{ width: size, height: size }}
    >
      {/* 1. Synchronized Expanding Radar Pulse Ring */}
      <div
        className="absolute rounded-full pointer-events-none transition-transform"
        style={{
          width: badgeSize,
          height: badgeSize,
          transform: `scale(${pulse.scale})`,
          border: `1.4px solid rgba(154, 111, 50, ${pulse.opacity})`,
          backgroundColor: `rgba(154, 111, 50, ${pulse.opacity * 0.12})`,
        }}
      />

      {/* 2. High-contrast Black & White Judicial Medallion Container */}
      <div
        className="relative rounded-full border-2 border-accent-light/80 shadow-md overflow-hidden flex items-center justify-center"
        style={{
          width: badgeSize,
          height: badgeSize,
          boxShadow: '0 2px 10px rgba(0, 0, 0, 0.35), inset 0 1px 2px rgba(255, 255, 255, 0.25)',
        }}
      >
        <canvas
          ref={canvasRef}
          style={{
            width: badgeSize,
            height: badgeSize,
            display: 'block',
          }}
        />
      </div>
    </div>
  );
}
