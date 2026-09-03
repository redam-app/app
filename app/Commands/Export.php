<?php

declare(strict_types=1);

namespace App\Commands;

use Illuminate\Contracts\Container\BindingResolutionException;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Export extends Base
{
    protected function getCommandName(): string
    {
        return 'export';
    }

    protected function getCommandDescription(): string
    {
        return 'Export to a dump file';
    }

    protected function getCommandParameters(): array
    {
        return [
            $this->prepareInputOption('file', 'Export file'),
            $this->prepareDefaultInputOption('tempDir', '/tmp/redam', 'Path to temp directory, default: /tmp/redam'),
            $this->prepareInputFlag('onlyColumns', 'Flag if only table columns are to be exported'),
            $this->prepareInputFlag('onlyRecords', 'Flag if only records are to be exported'),
            $this->prepareInputFlag('removeDatabase', 'Flag to remove the database after download'),
        ];
    }

    /**
     * @throws BindingResolutionException
     */
    protected function executeCommand(): int
    {
        $file = $this->getRequiredOption('file', 'No import file specified!');
        $tempDir = $this->getRequiredOption('tempDir', 'No temp directory specified!');
        $onlyColumns = $this->getFlag('onlyColumns');
        $onlyRecords = $this->getFlag('onlyRecords');
        $removeDatabase = $this->getFlag('removeDatabase');

        $process = $this->app->make(\App\Models\Process\Export::class);

        $process->execute(
            $this->getOutput(),
            $file,
            $tempDir,
            $onlyColumns,
            $onlyRecords,
            $removeDatabase
        );

        return self::SUCCESS;
    }
}
