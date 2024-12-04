<?php

declare(strict_types=1);

namespace Hgraca\Katas\Patterns\Behavioral\NullObject;

final class ReportX
{
    public function printX(): void
    {
        echo "X\n";
    }

    public function printY(): void
    {
        echo "Y\n";
    }

    public function printZ(): void
    {
        echo "Z\n";
    }
}
