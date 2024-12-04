<?php

declare(strict_types=1);

namespace Hgraca\Katas\Patterns\Behavioral\Template;

final class ReportGenerator
{
    public function generateReport(string $type): void
    {
        if ($type === 'Sales') {
            echo "Collecting sales data\n";
            echo "Formatting sales data into tables\n";
            echo "Adding sales-specific headers\n";
            echo "Adding standard footers\n";
        } elseif ($type === 'Inventory') {
            echo "Collecting inventory data\n";
            echo "Formatting inventory data into lists\n";
            echo "Adding standard headers\n";
            echo "Adding standard footers\n";
        }
        echo "Exporting the report\n";
    }
}
