<?php

declare(strict_types=1);

namespace Hgraca\Katas\Patterns\Behavioral\NullObject;

final readonly class ReportGenerator
{
    public function __construct(private ReportA $reportA, private ?ReportX $reportX = null)
    {
    }

    public function generateReport(): void
    {
        $this->reportA->printA();
        if ($this->reportX !== null) {
            $this->reportX->printX();
        }

        $this->reportA->printB();
        if ($this->reportX !== null) {
            $this->reportX->printY();
        }

        $this->reportA->printC();
        if ($this->reportX !== null) {
            $this->reportX->printZ();
        }
    }
}
